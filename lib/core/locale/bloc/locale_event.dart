part of 'locale_bloc.dart';

/// Locale events
sealed class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

/// Load locale preference from storage
class LocaleLoadRequested extends LocaleEvent {
  const LocaleLoadRequested();
}

/// Change app locale
class LocaleChanged extends LocaleEvent {
  const LocaleChanged(this.appLocale);

  final AppLocale appLocale;

  @override
  List<Object?> get props => [appLocale];
}
