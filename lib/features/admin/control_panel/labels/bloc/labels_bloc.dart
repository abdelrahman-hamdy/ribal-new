import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../data/models/label_model.dart';
import '../../../../../data/repositories/label_repository.dart';

part 'labels_event.dart';
part 'labels_state.dart';

@injectable
class LabelsBloc extends Bloc<LabelsEvent, LabelsState> {
  final LabelRepository _labelRepository;
  StreamSubscription? _labelsSubscription;

  LabelsBloc(this._labelRepository) : super(LabelsState.initial()) {
    on<LabelsLoadRequested>(_onLoadRequested);
    on<_LabelsDataReceived>(_onDataReceived);
    on<_LabelsErrorReceived>(_onErrorReceived);
    on<LabelCreateRequested>(_onCreateRequested);
    on<LabelUpdateRequested>(_onUpdateRequested);
    on<LabelToggleActiveRequested>(_onToggleActiveRequested);
    on<LabelDeleteRequested>(_onDeleteRequested);
    on<LabelsSearchRequested>(_onSearchRequested);
    on<LabelsSearchCleared>(_onSearchCleared);
  }

  Future<void> _onLoadRequested(
    LabelsLoadRequested event,
    Emitter<LabelsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _labelsSubscription?.cancel();

    _labelsSubscription = _labelRepository.streamAllLabels().listen(
      (labels) => add(_LabelsDataReceived(labels: labels)),
      onError: (error) => add(const _LabelsErrorReceived()),
    );
  }

  void _onDataReceived(
    _LabelsDataReceived event,
    Emitter<LabelsState> emit,
  ) {
    emit(state.copyWith(
      labels: event.labels,
      filteredLabels: _applySearch(event.labels, state.searchQuery),
      isLoading: false,
    ));
  }

  void _onErrorReceived(
    _LabelsErrorReceived event,
    Emitter<LabelsState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: 'فشل في تحميل التصنيفات',
    ));
  }

  Future<void> _onCreateRequested(
    LabelCreateRequested event,
    Emitter<LabelsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final label = LabelModel(
        id: '',
        name: event.name,
        color: event.color,
        isActive: true,
        createdBy: event.createdBy,
        createdAt: DateTime.now(),
      );
      await _labelRepository.createLabel(label);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم إنشاء التصنيف بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في إنشاء التصنيف',
      ));
    }
  }

  Future<void> _onUpdateRequested(
    LabelUpdateRequested event,
    Emitter<LabelsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _labelRepository.updateLabel(event.label);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم تحديث التصنيف بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحديث التصنيف',
      ));
    }
  }

  Future<void> _onToggleActiveRequested(
    LabelToggleActiveRequested event,
    Emitter<LabelsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _labelRepository.toggleLabelActive(event.labelId, event.isActive);
      emit(state.copyWith(
        successMessage: event.isActive ? 'تم تفعيل التصنيف' : 'تم إلغاء تفعيل التصنيف',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث حالة التصنيف',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    LabelDeleteRequested event,
    Emitter<LabelsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _labelRepository.deleteLabel(event.labelId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم حذف التصنيف بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في حذف التصنيف',
      ));
    }
  }

  void _onSearchRequested(
    LabelsSearchRequested event,
    Emitter<LabelsState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    emit(state.copyWith(
      searchQuery: query,
      filteredLabels: _applySearch(state.labels, query),
    ));
  }

  void _onSearchCleared(
    LabelsSearchCleared event,
    Emitter<LabelsState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      filteredLabels: state.labels,
    ));
  }

  List<LabelModel> _applySearch(List<LabelModel> labels, String query) {
    if (query.isEmpty) return labels;

    return labels.where((l) {
      final name = l.name.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  Future<void> close() {
    _labelsSubscription?.cancel();
    return super.close();
  }
}
