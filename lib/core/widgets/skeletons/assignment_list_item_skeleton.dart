import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Skeleton component for AssignmentListItem that matches exact dimensions
/// Used inside a Skeletonizer wrapper for smooth loading animation
class AssignmentListItemSkeleton extends StatelessWidget {
  const AssignmentListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Status badge + Deadline
          Row(
            children: [
              // Status badge
              Bone(
                width: 70,
                height: 22,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              Spacer(),
              // Deadline indicator
              Bone(
                width: 90,
                height: 16,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Task title
          Bone.text(words: 5, fontSize: 16),
          SizedBox(height: AppSpacing.md),

          // Action buttons row
          Row(
            children: [
              // Mark completed button
              Expanded(
                child: Bone(
                  height: 36,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Apologize button
              Expanded(
                child: Bone(
                  height: 36,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A list of AssignmentListItemSkeletons for loading state
class AssignmentListSkeletonList extends StatelessWidget {
  final int itemCount;

  const AssignmentListSkeletonList({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      child: ListView.separated(
        padding: AppSpacing.pagePadding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => const AssignmentListItemSkeleton(),
      ),
    );
  }
}
