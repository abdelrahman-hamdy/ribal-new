part of 'statistics_bloc.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsLoadRequested extends StatisticsEvent {
  const StatisticsLoadRequested();
}

class StatisticsPeriodChanged extends StatisticsEvent {
  final StatisticsPeriod period;

  const StatisticsPeriodChanged({required this.period});

  @override
  List<Object?> get props => [period];
}
