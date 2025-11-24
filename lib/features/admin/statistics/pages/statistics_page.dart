import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/empty_state.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'اليوم'),
            Tab(text: 'هذا الأسبوع'),
            Tab(text: 'هذا الشهر'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsView('today'),
          _buildStatisticsView('week'),
          _buildStatisticsView('month'),
        ],
      ),
    );
  }

  Widget _buildStatisticsView(String period) {
    // TODO: Implement statistics view with real data
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          _buildOverviewSection(),
          const SizedBox(height: AppSpacing.lg),

          // Completion rate
          _buildSectionTitle('معدل الإنجاز'),
          _buildProgressCard('معدل إكمال المهام', 0, AppColors.success),
          _buildProgressCard('معدل الاعتذار', 0, AppColors.warning),
          const SizedBox(height: AppSpacing.lg),

          // Top performers
          _buildSectionTitle('أفضل الموظفين'),
          const EmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'لا توجد بيانات',
            message: 'لم يتم تسجيل أي مهام في هذه الفترة',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('إجمالي المهام', '0', AppColors.primary)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildStatCard('المكتملة', '0', AppColors.success)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildStatCard('المعتذرين', '0', AppColors.warning)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: AppSpacing.cardPaddingSm,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: AppTypography.headlineSmall),
    );
  }

  Widget _buildProgressCard(String title, double percentage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.titleMedium),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.titleMedium.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: AppSpacing.borderRadiusFull,
          ),
        ],
      ),
    );
  }
}
