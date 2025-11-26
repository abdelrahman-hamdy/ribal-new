part of 'notes_bloc.dart';

class NotesState extends Equatable {
  final bool isLoading;
  final bool isSending;
  final List<NoteModel> notes;
  final String? errorMessage;
  final String? successMessage;

  const NotesState({
    this.isLoading = false,
    this.isSending = false,
    this.notes = const [],
    this.errorMessage,
    this.successMessage,
  });

  factory NotesState.initial() => const NotesState();

  NotesState copyWith({
    bool? isLoading,
    bool? isSending,
    List<NoteModel>? notes,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return NotesState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      notes: notes ?? this.notes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// Check if there are any notes
  bool get hasNotes => notes.isNotEmpty;

  /// Get notes count
  int get notesCount => notes.length;

  @override
  List<Object?> get props => [
        isLoading,
        isSending,
        notes,
        errorMessage,
        successMessage,
      ];
}
