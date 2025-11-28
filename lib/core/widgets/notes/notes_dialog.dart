import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/injection.dart';
import '../../../data/models/user_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../avatar/ribal_avatar.dart';
import 'bloc/notes_bloc.dart';
import 'note_input.dart';
import 'notes_list.dart';

/// Dialog to view notes for a specific assignment
/// Used by task creators to view and reply to notes from assignees
class NotesDialog extends StatelessWidget {
  final String assignmentId;
  final String taskId;
  final String assigneeName;
  final UserRole assigneeRole;
  final String currentUserId;
  final String currentUserName;
  final UserRole currentUserRole;

  // For notifications (assigneeId is the recipient when task creator sends a note)
  final String? assigneeId;
  final String? taskTitle;

  const NotesDialog({
    super.key,
    required this.assignmentId,
    required this.taskId,
    required this.assigneeName,
    required this.assigneeRole,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
    this.assigneeId,
    this.taskTitle,
  });

  /// Show the notes dialog
  static Future<void> show({
    required BuildContext context,
    required String assignmentId,
    required String taskId,
    required String assigneeName,
    required UserRole assigneeRole,
    required String currentUserId,
    required String currentUserName,
    required UserRole currentUserRole,
    String? assigneeId,
    String? taskTitle,
  }) {
    return showDialog(
      context: context,
      builder: (context) => NotesDialog(
        assignmentId: assignmentId,
        taskId: taskId,
        assigneeName: assigneeName,
        assigneeRole: assigneeRole,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserRole: currentUserRole,
        assigneeId: assigneeId,
        taskTitle: taskTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotesBloc>()
        ..add(NotesStreamStarted(assignmentId: assignmentId)),
      child: Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        clipBehavior: Clip.antiAlias,
        child: _NotesDialogContent(
          assigneeName: assigneeName,
          assigneeRole: assigneeRole,
          assignmentId: assignmentId,
          taskId: taskId,
          currentUserId: currentUserId,
          currentUserName: currentUserName,
          currentUserRole: currentUserRole,
          assigneeId: assigneeId,
          taskTitle: taskTitle,
        ),
      ),
    );
  }
}

class _NotesDialogContent extends StatefulWidget {
  final String assigneeName;
  final UserRole assigneeRole;
  final String assignmentId;
  final String taskId;
  final String currentUserId;
  final String currentUserName;
  final UserRole currentUserRole;
  final String? assigneeId;
  final String? taskTitle;

  const _NotesDialogContent({
    required this.assigneeName,
    required this.assigneeRole,
    required this.assignmentId,
    required this.taskId,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
    this.assigneeId,
    this.taskTitle,
  });

  @override
  State<_NotesDialogContent> createState() => _NotesDialogContentState();
}

class _NotesDialogContentState extends State<_NotesDialogContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.7;

    return BlocConsumer<NotesBloc, NotesState>(
      listenWhen: (previous, current) {
        return previous.notes.length < current.notes.length;
      },
      listener: (context, state) {
        _scrollToBottom();

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<NotesBloc>().add(const NotesClearMessages());
        }
      },
      builder: (context, state) {
        return Container(
          height: dialogHeight,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // Header
              _buildHeader(context, state),
              Divider(height: 1, color: context.colors.border),
              // Notes list
              Expanded(
                child: NotesList(
                  notes: state.notes,
                  currentUserId: widget.currentUserId,
                  isLoading: state.isLoading,
                  scrollController: _scrollController,
                ),
              ),
              // Input
              NoteInput(
                isSending: state.isSending,
                hintText: AppLocalizations.of(context)!.notes_writeReply,
                onSend: (message) {
                  context.read<NotesBloc>().add(NoteSendRequested(
                        assignmentId: widget.assignmentId,
                        taskId: widget.taskId,
                        senderId: widget.currentUserId,
                        senderName: widget.currentUserName,
                        senderRole: widget.currentUserRole,
                        message: message,
                        recipientId: widget.assigneeId,
                        taskTitle: widget.taskTitle,
                      ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, NotesState state) {
    final l10n = AppLocalizations.of(context)!;
    // Ensure assigneeName is not empty
    final displayName = widget.assigneeName.trim().isEmpty
        ? l10n.user_unknown
        : widget.assigneeName;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // Avatar - using unified RibalAvatar with role-specific image
          RibalAvatar.fromData(
            initials: displayName.isNotEmpty
                ? displayName[0].toUpperCase()
                : '?',
            role: widget.assigneeRole,
            size: RibalAvatarSize.md,
          ),
          const SizedBox(width: AppSpacing.smd),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notes_notesOf(displayName),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.hasNotes)
                  Text(
                    '${state.notesCount} ${l10n.notes_notesSingular}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
