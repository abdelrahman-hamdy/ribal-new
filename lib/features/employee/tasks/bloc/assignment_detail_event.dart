part of 'assignment_detail_bloc.dart';

abstract class AssignmentDetailEvent extends Equatable {
  const AssignmentDetailEvent();

  @override
  List<Object?> get props => [];
}

class AssignmentDetailLoadRequested extends AssignmentDetailEvent {
  final String assignmentId;

  const AssignmentDetailLoadRequested({required this.assignmentId});

  @override
  List<Object?> get props => [assignmentId];
}

class AssignmentDetailMarkCompletedRequested extends AssignmentDetailEvent {
  final String assignmentId;
  final String markedDoneBy;
  final String? attachmentUrl;

  const AssignmentDetailMarkCompletedRequested({
    required this.assignmentId,
    required this.markedDoneBy,
    this.attachmentUrl,
  });

  @override
  List<Object?> get props => [assignmentId, markedDoneBy, attachmentUrl];
}

class AssignmentDetailApologizeRequested extends AssignmentDetailEvent {
  final String assignmentId;
  final String? message;

  const AssignmentDetailApologizeRequested({
    required this.assignmentId,
    this.message,
  });

  @override
  List<Object?> get props => [assignmentId, message];
}

class AssignmentDetailReactivateRequested extends AssignmentDetailEvent {
  final String assignmentId;

  const AssignmentDetailReactivateRequested({required this.assignmentId});

  @override
  List<Object?> get props => [assignmentId];
}
