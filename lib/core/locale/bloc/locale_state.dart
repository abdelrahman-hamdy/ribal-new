part of 'locale_bloc.dart';

/// Locale state
class LocaleState extends Equatable {
  const LocaleState({
    this.appLocale = AppLocale.arabic,
    this.isLoading = false,
  });

  /// Current app locale
  final AppLocale appLocale;

  /// Whether locale is being loaded
  final bool isLoading;

  /// Get the Flutter Locale based on AppLocale
  Locale get locale => appLocale.locale;

  /// Initial state
  factory LocaleState.initial() => const LocaleState(isLoading: true);

  LocaleState copyWith({
    AppLocale? appLocale,
    bool? isLoading,
  }) {
    return LocaleState(
      appLocale: appLocale ?? this.appLocale,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [appLocale, isLoading];
}
