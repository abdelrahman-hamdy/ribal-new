part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Start streaming notes for an assignment
class NotesStreamStarted extends NotesEvent {
  final String assignmentId;

  const NotesStreamStarted({required this.assignmentId});

  @override
  List<Object?> get props => [assignmentId];
}

/// Notes received from stream
class NotesUpdated extends NotesEvent {
  final List<NoteModel> notes;

  const NotesUpdated({required this.notes});

  @override
  List<Object?> get props => [notes];
}

/// Send a new note
class NoteSendRequested extends NotesEvent {
  final String assignmentId;
  final String taskId;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String message;
  final bool isApologizeNote;

  // For notifications
  final String? recipientId;
  final String? taskTitle;

  const NoteSendRequested({
    required this.assignmentId,
    required this.taskId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    this.isApologizeNote = false,
    this.recipientId,
    this.taskTitle,
  });

  @override
  List<Object?> get props => [
        assignmentId,
        taskId,
        senderId,
        senderName,
        senderRole,
        message,
        isApologizeNote,
        recipientId,
        taskTitle,
      ];
}

/// Clear success/error messages
class NotesClearMessages extends NotesEvent {
  const NotesClearMessages();
}
