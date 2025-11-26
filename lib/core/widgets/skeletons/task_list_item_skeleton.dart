import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Skeleton component for TaskListItem that matches exact dimensions
/// Used inside a Skeletonizer wrapper for smooth loading animation
class TaskListItemSkeleton extends StatelessWidget {
  const TaskListItemSkeleton({super.key});

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
          // Labels row (2 label chips)
          Row(
            children: [
              // Label chip 1
              Bone(
                width: 60,
                height: 22,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              SizedBox(width: AppSpacing.xs),
              // Label chip 2
              Bone(
                width: 48,
                height: 22,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // Title row with deadline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Expanded(
                child: Bone.text(words: 4, fontSize: 18),
              ),
              SizedBox(width: AppSpacing.sm),
              // Deadline badge
              Bone(
                width: 50,
                height: 16,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.smd),

          // Bottom row: Creator + Progress
          Row(
            children: [
              // Creator avatar
              Bone.circle(size: 20),
              SizedBox(width: AppSpacing.xs),
              // Creator name
              Bone.text(words: 2, fontSize: 12),
              Spacer(),
              // Progress badge
              Bone(
                width: 80,
                height: 24,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A list of TaskListItemSkeletons for loading state
class TaskListSkeletonList extends StatelessWidget {
  final int itemCount;

  const TaskListSkeletonList({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => const TaskListItemSkeleton(),
      ),
    );
  }
}
