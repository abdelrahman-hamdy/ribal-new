import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/ksa_timezone.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/statistics_repository.dart';
import '../../../../data/repositories/user_repository.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

@injectable
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StatisticsRepository _statisticsRepository;
  final UserRepository _userRepository;

  StatisticsBloc(this._statisticsRepository, this._userRepository)
      : super(StatisticsState.initial()) {
    on<StatisticsLoadRequested>(_onLoadRequested);
    on<StatisticsPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onLoadRequested(
    StatisticsLoadRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Load statistics for current period
      final stats = await _getStatisticsForPeriod(state.period);

      // Load top performers
      final performances = await _getPerformancesForPeriod(state.period);

      // Get user details for performers (batch fetch for performance)
      final topPerformancesList = performances.take(5).toList();
      final userIds = topPerformancesList.map((p) => p.userId).toList();
      final usersMap = await _userRepository.getUsersByIds(userIds);

      final topPerformers = topPerformancesList
          .where((perf) => usersMap.containsKey(perf.userId))
          .map((perf) => TopPerformer(
                user: usersMap[perf.userId]!,
                performance: perf,
              ))
          .toList();

      emit(state.copyWith(
        isLoading: false,
        statistics: stats,
        topPerformers: topPerformers,
      ));
    } catch (e, stackTrace) {
      debugPrint('[StatisticsBloc] ❌ Error loading statistics: $e');
      debugPrint('[StatisticsBloc] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل الإحصائيات',
      ));
    }
  }

  Future<void> _onPeriodChanged(
    StatisticsPeriodChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state.period == event.period) return;

    emit(state.copyWith(period: event.period, isLoading: true, clearError: true));

    try {
      final stats = await _getStatisticsForPeriod(event.period);
      final performances = await _getPerformancesForPeriod(event.period);

      // Get user details for performers (batch fetch for performance)
      final topPerformancesList = performances.take(5).toList();
      final userIds = topPerformancesList.map((p) => p.userId).toList();
      final usersMap = await _userRepository.getUsersByIds(userIds);

      final topPerformers = topPerformancesList
          .where((perf) => usersMap.containsKey(perf.userId))
          .map((perf) => TopPerformer(
                user: usersMap[perf.userId]!,
                performance: perf,
              ))
          .toList();

      emit(state.copyWith(
        isLoading: false,
        statistics: stats,
        topPerformers: topPerformers,
      ));
    } catch (e, stackTrace) {
      debugPrint('[StatisticsBloc] ❌ Error loading statistics: $e');
      debugPrint('[StatisticsBloc] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل الإحصائيات',
      ));
    }
  }

  Future<StatisticsData> _getStatisticsForPeriod(StatisticsPeriod period) {
    switch (period) {
      case StatisticsPeriod.today:
        return _statisticsRepository.getTodayStatistics();
      case StatisticsPeriod.week:
        return _statisticsRepository.getWeekStatistics();
      case StatisticsPeriod.month:
        return _statisticsRepository.getMonthStatistics();
    }
  }

  Future<List<UserPerformance>> _getPerformancesForPeriod(
      StatisticsPeriod period) async {
    switch (period) {
      case StatisticsPeriod.today:
        final start = KsaTimezone.startOfToday();
        final end = start.add(const Duration(days: 1));
        return _statisticsRepository.getUserPerformance(
            startDate: start, endDate: end);
      case StatisticsPeriod.week:
        final start = KsaTimezone.startOfWeek();
        final end = KsaTimezone.endOfWeek();
        return _statisticsRepository.getUserPerformance(
            startDate: start, endDate: end);
      case StatisticsPeriod.month:
        final start = KsaTimezone.startOfMonth();
        final end = KsaTimezone.endOfMonth();
        return _statisticsRepository.getUserPerformance(
            startDate: start, endDate: end);
    }
  }
}
