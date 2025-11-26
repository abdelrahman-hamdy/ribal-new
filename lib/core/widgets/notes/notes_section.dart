import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/injection.dart';
import '../../../data/models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'bloc/notes_bloc.dart';
import 'note_input.dart';
import 'notes_list.dart';

/// A complete notes section with list and input
/// Used in assignment detail pages
class NotesSection extends StatelessWidget {
  final String assignmentId;
  final String taskId;
  final String currentUserId;
  final String currentUserName;
  final UserRole currentUserRole;
  final double? height;

  // For notifications
  final String? recipientId;
  final String? taskTitle;

  const NotesSection({
    super.key,
    required this.assignmentId,
    required this.taskId,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
    this.height,
    this.recipientId,
    this.taskTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotesBloc>()
        ..add(NotesStreamStarted(assignmentId: assignmentId)),
      child: _NotesSectionContent(
        assignmentId: assignmentId,
        taskId: taskId,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserRole: currentUserRole,
        height: height,
        recipientId: recipientId,
        taskTitle: taskTitle,
      ),
    );
  }
}

class _NotesSectionContent extends StatefulWidget {
  final String assignmentId;
  final String taskId;
  final String currentUserId;
  final String currentUserName;
  final UserRole currentUserRole;
  final double? height;
  final String? recipientId;
  final String? taskTitle;

  const _NotesSectionContent({
    required this.assignmentId,
    required this.taskId,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
    this.height,
    this.recipientId,
    this.taskTitle,
  });

  @override
  State<_NotesSectionContent> createState() => _NotesSectionContentState();
}

class _NotesSectionContentState extends State<_NotesSectionContent> {
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
    return BlocConsumer<NotesBloc, NotesState>(
      listenWhen: (previous, current) {
        // Scroll to bottom when new notes arrive
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
          height: widget.height ?? 400,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(state),
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
                onSend: (message) {
                  context.read<NotesBloc>().add(NoteSendRequested(
                        assignmentId: widget.assignmentId,
                        taskId: widget.taskId,
                        senderId: widget.currentUserId,
                        senderName: widget.currentUserName,
                        senderRole: widget.currentUserRole,
                        message: message,
                        recipientId: widget.recipientId,
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

  Widget _buildHeader(NotesState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'الملاحظات',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          if (state.hasNotes) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                '${state.notesCount}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
