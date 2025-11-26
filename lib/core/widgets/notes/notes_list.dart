import 'package:flutter/material.dart';

import '../../../data/models/note_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/ksa_timezone.dart';
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

        // Add date separator if needed
        final showDateSeparator = _shouldShowDateSeparator(index);

        return Column(
          children: [
            if (showDateSeparator) _buildDateSeparator(context, notes[index].createdAt),
            NoteBubble(
              note: note,
              isCurrentUser: isCurrentUser,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'لا توجد ملاحظات بعد',
            style: AppTypography.bodyLarge.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'ابدأ المحادثة بإرسال ملاحظة',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == 0) return true;

    final currentDate = DateTime(
      notes[index].createdAt.year,
      notes[index].createdAt.month,
      notes[index].createdAt.day,
    );

    final previousDate = DateTime(
      notes[index - 1].createdAt.year,
      notes[index - 1].createdAt.month,
      notes[index - 1].createdAt.day,
    );

    return currentDate != previousDate;
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.colors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              _formatDateSeparator(date),
              style: AppTypography.labelSmall.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ),
          Expanded(child: Divider(color: context.colors.border)),
        ],
      ),
    );
  }

  String _formatDateSeparator(DateTime date) {
    final today = KsaTimezone.today();
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'اليوم';
    } else if (noteDate == today.subtract(const Duration(days: 1))) {
      return 'أمس';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
