part of 'labels_bloc.dart';

/// Labels events
abstract class LabelsEvent extends Equatable {
  const LabelsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all labels
class LabelsLoadRequested extends LabelsEvent {
  const LabelsLoadRequested();
}

/// Create new label
class LabelCreateRequested extends LabelsEvent {
  final String name;
  final String color;
  final String createdBy;

  const LabelCreateRequested({
    required this.name,
    required this.color,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [name, color, createdBy];
}

/// Update label
class LabelUpdateRequested extends LabelsEvent {
  final LabelModel label;

  const LabelUpdateRequested({required this.label});

  @override
  List<Object?> get props => [label];
}

/// Toggle label active status
class LabelToggleActiveRequested extends LabelsEvent {
  final String labelId;
  final bool isActive;

  const LabelToggleActiveRequested({
    required this.labelId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [labelId, isActive];
}

/// Delete label
class LabelDeleteRequested extends LabelsEvent {
  final String labelId;

  const LabelDeleteRequested({required this.labelId});

  @override
  List<Object?> get props => [labelId];
}

/// Search labels
class LabelsSearchRequested extends LabelsEvent {
  final String query;

  const LabelsSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search
class LabelsSearchCleared extends LabelsEvent {
  const LabelsSearchCleared();
}

/// Internal: Data received from stream
class _LabelsDataReceived extends LabelsEvent {
  final List<LabelModel> labels;

  const _LabelsDataReceived({required this.labels});

  @override
  List<Object?> get props => [labels];
}

/// Internal: Error received from stream
class _LabelsErrorReceived extends LabelsEvent {
  const _LabelsErrorReceived();
}
