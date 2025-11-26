import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:ribal/data/models/note_model.dart';
import 'package:ribal/data/models/notification_model.dart';
import 'package:ribal/data/models/user_model.dart';
import 'package:ribal/data/repositories/note_repository.dart';
import 'package:ribal/data/repositories/notification_repository.dart';

part 'notes_event.dart';
part 'notes_state.dart';

@injectable
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _noteRepository;
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<NoteModel>>? _notesSubscription;

  NotesBloc(this._noteRepository, this._notificationRepository)
      : super(NotesState.initial()) {
    on<NotesStreamStarted>(_onStreamStarted);
    on<NotesUpdated>(_onNotesUpdated);
    on<NoteSendRequested>(_onSendRequested);
    on<NotesClearMessages>(_onClearMessages);
  }

  Future<void> _onStreamStarted(
    NotesStreamStarted event,
    Emitter<NotesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    // Cancel any existing subscription
    await _notesSubscription?.cancel();

    // Start streaming notes
    _notesSubscription = _noteRepository
        .streamNotesForAssignment(event.assignmentId)
        .listen(
          (notes) {
            if (!isClosed) {
              add(NotesUpdated(notes: notes));
            }
          },
          onError: (error) {
            if (!isClosed) {
              add(const NotesUpdated(notes: []));
            }
          },
        );
  }

  void _onNotesUpdated(
    NotesUpdated event,
    Emitter<NotesState> emit,
  ) {
    // Find any optimistic notes (temporary IDs starting with 'temp_')
    final optimisticNotes =
        state.notes.where((n) => n.id.startsWith('temp_')).toList();

    if (optimisticNotes.isEmpty) {
      // No optimistic notes, just use stream data normally
      emit(state.copyWith(
        isLoading: false,
        notes: event.notes,
        isSending: false,
      ));
      return;
    }

    // Check if any optimistic notes are now in the stream (real notes)
    final remainingOptimistic = <NoteModel>[];
    for (final optNote in optimisticNotes) {
      // Look for a matching real note (similar timestamp, same message and sender)
      final hasMatchingReal = event.notes.any((realNote) {
        final timeDiff = realNote.createdAt.difference(optNote.createdAt).abs();
        return timeDiff.inSeconds < 5 &&
            realNote.message == optNote.message &&
            realNote.senderId == optNote.senderId;
      });

      // If no matching real note found, keep the optimistic one
      if (!hasMatchingReal) {
        remainingOptimistic.add(optNote);
      }
    }

    // Merge stream notes with any remaining optimistic notes
    final mergedNotes = [...event.notes, ...remainingOptimistic];

    emit(state.copyWith(
      isLoading: false,
      notes: mergedNotes,
      isSending: remainingOptimistic.isNotEmpty,
    ));
  }

  Future<void> _onSendRequested(
    NoteSendRequested event,
    Emitter<NotesState> emit,
  ) async {
    // Create optimistic note to show immediately
    final optimisticNote = NoteModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      assignmentId: event.assignmentId,
      taskId: event.taskId,
      senderId: event.senderId,
      senderName: event.senderName,
      senderRole: event.senderRole,
      message: event.message,
      isApologizeNote: event.isApologizeNote,
      createdAt: DateTime.now(),
    );

    // Add optimistic note to the list and set sending state
    final updatedNotes = [...state.notes, optimisticNote];
    emit(state.copyWith(
      isSending: true,
      notes: updatedNotes,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _noteRepository.createNote(
        assignmentId: event.assignmentId,
        taskId: event.taskId,
        senderId: event.senderId,
        senderName: event.senderName,
        senderRole: event.senderRole,
        message: event.message,
        isApologizeNote: event.isApologizeNote,
      );

      // Send notification to recipient if provided
      if (event.recipientId != null && event.recipientId != event.senderId) {
        final taskTitle = event.taskTitle ?? 'مهمة';
        final notificationTitle = event.isApologizeNote
            ? 'اعتذار جديد عن المهمة'
            : 'ملاحظة جديدة على المهمة';
        final notificationBody = event.isApologizeNote
            ? '${event.senderName} اعتذر عن "$taskTitle": ${event.message}'
            : '${event.senderName} أضاف ملاحظة على "$taskTitle": ${event.message}';

        await _notificationRepository.createTypedNotification(
          userId: event.recipientId!,
          type: NotificationType.noteReceived,
          title: notificationTitle,
          body: notificationBody,
          deepLink: '/assignment/${event.assignmentId}',
        );
      }

      // Note: The stream will automatically update with the real note
      // Just clear the sending state
      emit(state.copyWith(
        isSending: false,
        successMessage: 'تم إرسال الملاحظة',
      ));
    } catch (e) {
      // Remove optimistic note on error
      final notesWithoutOptimistic = state.notes
          .where((n) => n.id != optimisticNote.id)
          .toList();
      emit(state.copyWith(
        isSending: false,
        notes: notesWithoutOptimistic,
        errorMessage: 'فشل في إرسال الملاحظة',
      ));
    }
  }

  void _onClearMessages(
    NotesClearMessages event,
    Emitter<NotesState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
