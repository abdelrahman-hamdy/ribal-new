part of 'statistics_bloc.dart';

enum StatisticsPeriod {
  today,
  week,
  month,
}

extension StatisticsPeriodX on StatisticsPeriod {
  String get displayNameAr {
    switch (this) {
      case StatisticsPeriod.today:
        return 'اليوم';
      case StatisticsPeriod.week:
        return 'هذا الأسبوع';
      case StatisticsPeriod.month:
        return 'هذا الشهر';
    }
  }
}

class TopPerformer {
  final UserModel user;
  final UserPerformance performance;

  const TopPerformer({
    required this.user,
    required this.performance,
  });
}

class StatisticsState extends Equatable {
  final bool isLoading;
  final StatisticsPeriod period;
  final StatisticsData? statistics;
  final List<TopPerformer> topPerformers;
  final String? errorMessage;

  const StatisticsState({
    this.isLoading = false,
    this.period = StatisticsPeriod.today,
    this.statistics,
    this.topPerformers = const [],
    this.errorMessage,
  });

  factory StatisticsState.initial() => const StatisticsState();

  StatisticsState copyWith({
    bool? isLoading,
    StatisticsPeriod? period,
    StatisticsData? statistics,
    List<TopPerformer>? topPerformers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      period: period ?? this.period,
      statistics: statistics ?? this.statistics,
      topPerformers: topPerformers ?? this.topPerformers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        period,
        statistics,
        topPerformers,
        errorMessage,
      ];
}
