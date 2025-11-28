import 'package:flutter/material.dart';

import '../../../data/models/note_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'note_bubble.dart';

/// Scrollable list of notes with empty state
class NotesList extends StatelessWidget {
  final List<NoteModel> notes;
  final String currentUserId;
  final bool isLoading;
  final ScrollController? scrollController;

  const NotesList({
    super.key,
    required this.notes,
    required this.currentUserId,
    this.isLoading = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (notes.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isCurrentUser = note.senderId == currentUserId;

        // No date separators - notes are always for today
        return NoteBubble(
          note: note,
          isCurrentUser: isCurrentUser,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: context.colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.notes_noNotesYet,
            style: AppTypography.bodyLarge.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.notes_startConversation,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
