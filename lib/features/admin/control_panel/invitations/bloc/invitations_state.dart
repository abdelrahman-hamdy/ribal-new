part of 'invitations_bloc.dart';

/// Invitations state
class InvitationsState extends Equatable {
  final List<InvitationModel> invitations;
  final List<InvitationModel> filteredInvitations;
  final bool? showUsedOnly;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? lastCreatedCode;

  const InvitationsState({
    this.invitations = const [],
    this.filteredInvitations = const [],
    this.showUsedOnly,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.lastCreatedCode,
  });

  factory InvitationsState.initial() => const InvitationsState();

  InvitationsState copyWith({
    List<InvitationModel>? invitations,
    List<InvitationModel>? filteredInvitations,
    bool? showUsedOnly,
    bool clearShowUsedOnly = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? lastCreatedCode,
  }) {
    return InvitationsState(
      invitations: invitations ?? this.invitations,
      filteredInvitations: filteredInvitations ?? this.filteredInvitations,
      showUsedOnly: clearShowUsedOnly ? null : (showUsedOnly ?? this.showUsedOnly),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      lastCreatedCode: lastCreatedCode ?? this.lastCreatedCode,
    );
  }

  @override
  List<Object?> get props => [
        invitations,
        filteredInvitations,
        showUsedOnly,
        isLoading,
        errorMessage,
        successMessage,
        lastCreatedCode,
      ];

  /// Get used invitations count
  int get usedCount => invitations.where((i) => i.used).length;

  /// Get unused invitations count
  int get unusedCount => invitations.where((i) => !i.used).length;
}
