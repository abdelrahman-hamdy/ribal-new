import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

/// Model representing a note/comment on an assignment
@freezed
class NoteModel with _$NoteModel {
  const NoteModel._();

  const factory NoteModel({
    required String id,
    required String assignmentId,
    required String taskId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String message,
    @Default(false) bool isApologizeNote,
    required DateTime createdAt,
  }) = _NoteModel;

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      assignmentId: data['assignmentId'] as String,
      taskId: data['taskId'] as String,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      senderRole: UserRole.values.firstWhere(
        (e) => e.name == data['senderRole'],
        orElse: () => UserRole.employee,
      ),
      message: data['message'] as String,
      isApologizeNote: data['isApologizeNote'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'taskId': taskId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole.name,
      'message': message,
      'isApologizeNote': isApologizeNote,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Check if this note was sent by the given user
  bool isSentBy(String userId) => senderId == userId;

  /// Get a truncated preview of the message
  String get preview {
    if (message.length <= 50) return message;
    return '${message.substring(0, 50)}...';
  }
}
