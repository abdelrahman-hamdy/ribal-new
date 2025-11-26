# Flutter Widget Optimization Guide

**Project:** Ribal Flutter App
**Purpose:** Best practices for optimizing widget performance

---

## 🎯 Overview

Widget optimization is crucial for smooth UI performance. This guide covers:
1. **Const constructors** - Prevent unnecessary rebuilds
2. **Selective BLoC rebuilds** - Use `buildWhen`/`listenWhen`
3. **Keys** - Preserve widget state
4. **RepaintBoundary** - Isolate expensive painting
5. **Skeleton loaders** - Better perceived performance

---

## 1. Const Constructors

### ✅ Rule: Use `const` wherever possible

**Why?**
- Widgets with `const` constructors are only built once
- Flutter reuses the same instance instead of rebuilding
- Significant performance improvement in large widget trees

### Examples

#### ❌ Bad - Non-const widget
```dart
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16),  // ❌ Creates new EdgeInsets on every build
    child: Text('مرحباً'),  // ❌ Creates new Text widget on every build
  );
}
```

#### ✅ Good - Const widget
```dart
Widget build(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(16),  // ✅ Reuses same EdgeInsets
    child: Text('مرحباً'),  // ✅ Reuses same Text widget
  );
}
```

### Where to Use Const

1. **Static text widgets**
```dart
const Text('عنوان الصفحة')
const Icon(Icons.home)
```

2. **Static padding/margins**
```dart
const EdgeInsets.all(16)
const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
const SizedBox(height: 20)
const Divider()
```

3. **Static containers**
```dart
const Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('محتوى ثابت'),
  ),
)
```

4. **Entire static widgets**
```dart
class StaticHeader extends StatelessWidget {
  const StaticHeader({super.key});  // ✅ Const constructor

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.star),
        SizedBox(width: 8),
        Text('عنوان'),
      ],
    );
  }
}
```

### Quick Audit

Run this command to find widgets that can be const:
```bash
# Find widgets without const
grep -r "class.*StatelessWidget" lib/ --include="*.dart" | \
  while read -r line; do
    echo "$line"
  done
```

---

## 2. Selective BLoC Rebuilds

### ✅ Rule: Use `buildWhen` and `listenWhen` to prevent unnecessary rebuilds

**Why?**
- By default, BlocBuilder rebuilds on EVERY state change
- Most widgets only care about specific state properties
- Selective rebuilds reduce wasted CPU cycles

### Examples

#### ❌ Bad - Rebuilds on every state change
```dart
BlocBuilder<TaskDetailBloc, TaskDetailState>(
  builder: (context, state) {
    // Rebuilds even if only errorMessage changed!
    return Text(state.task?.title ?? '');
  },
)
```

#### ✅ Good - Rebuilds only when task changes
```dart
BlocBuilder<TaskDetailBloc, TaskDetailState>(
  buildWhen: (previous, current) => previous.task != current.task,
  builder: (context, state) {
    // Only rebuilds when task actually changes
    return Text(state.task?.title ?? '');
  },
)
```

### Common Patterns

#### 1. Loading indicator
```dart
BlocBuilder<TaskDetailBloc, TaskDetailState>(
  buildWhen: (previous, current) => previous.isLoading != current.isLoading,
  builder: (context, state) {
    if (state.isLoading) {
      return const CircularProgressIndicator();
    }
    return const SizedBox.shrink();
  },
)
```

#### 2. Task list
```dart
BlocBuilder<TodayTasksBloc, TodayTasksState>(
  buildWhen: (previous, current) =>
    previous.tasks != current.tasks ||
    previous.isLoading != current.isLoading,
  builder: (context, state) {
    return ListView.builder(...);
  },
)
```

#### 3. Error message
```dart
BlocListener<TaskDetailBloc, TaskDetailState>(
  listenWhen: (previous, current) =>
    previous.errorMessage != current.errorMessage &&
    current.errorMessage != null,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.errorMessage!)),
    );
  },
  child: ...,
)
```

### BlocConsumer Optimization
```dart
BlocConsumer<TaskDetailBloc, TaskDetailState>(
  listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
  buildWhen: (previous, current) => previous.task != current.task,
  listener: (context, state) {
    if (state.errorMessage != null) {
      // Show error
    }
  },
  builder: (context, state) {
    // Build UI
  },
)
```

---

## 3. Widget Keys

### ✅ Rule: Use keys for lists and conditional widgets

**Why?**
- Preserves widget state during rebuilds
- Helps Flutter identify widgets efficiently
- Critical for animated lists and reorderable items

### When to Use Keys

#### 1. List items
```dart
ListView.builder(
  itemCount: tasks.length,
  itemBuilder: (context, index) {
    final task = tasks[index];
    return TaskCard(
      key: ValueKey(task.id),  // ✅ Preserves state when list changes
      task: task,
    );
  },
)
```

#### 2. Conditional widgets
```dart
Widget build(BuildContext context) {
  return user.isManager
    ? ManagerDashboard(key: const ValueKey('manager'))
    : EmployeeDashboard(key: const ValueKey('employee'));
}
```

#### 3. Stateful widgets in lists
```dart
class TaskCard extends StatefulWidget {
  const TaskCard({
    required Key key,  // ✅ Required for stateful widgets in lists
    required this.task,
  }) : super(key: key);

  final TaskModel task;

  @override
  State<TaskCard> createState() => _TaskCardState();
}
```

### Key Types

- `ValueKey(value)` - For unique values (IDs, names)
- `ObjectKey(object)` - For objects
- `UniqueKey()` - For guaranteed uniqueness (use sparingly)
- `GlobalKey()` - For accessing widget from anywhere (use sparingly)

---

## 4. RepaintBoundary

### ✅ Rule: Use RepaintBoundary for expensive widgets

**Why?**
- Isolates widget repainting
- Prevents parent rebuilds from triggering child repaints
- Useful for complex visualizations, images, animations

### Examples

#### 1. Complex charts
```dart
RepaintBoundary(
  child: StatisticsChart(data: statsData),
)
```

#### 2. List items with images
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: TaskCard(task: tasks[index]),
    );
  },
)
```

#### 3. Expensive custom painters
```dart
RepaintBoundary(
  child: CustomPaint(
    painter: ComplexBackgroundPainter(),
    child: child,
  ),
)
```

### ⚠️ Warning
Don't overuse RepaintBoundary:
- Each boundary creates a separate render layer (memory cost)
- Only use for genuinely expensive widgets
- Profile first, optimize second

---

## 5. Skeleton Loaders (Skeletonizer)

### ✅ Rule: Show skeleton loaders for better perceived performance

**Why?**
- Users perceive loading as faster
- Better UX than blank screens or spinners
- Already installed: `skeletonizer` package

### Implementation

#### Current Usage
```dart
// Already used in some places
Skeletonizer(
  enabled: state.isLoading,
  child: ListView.builder(...),
)
```

#### Recommended Pattern
```dart
Widget build(BuildContext context) {
  return BlocBuilder<TasksBloc, TasksState>(
    buildWhen: (previous, current) =>
      previous.tasks != current.tasks ||
      previous.loadingState != current.loadingState,
    builder: (context, state) {
      // Show skeleton on initial load
      final showSkeleton = state.loadingState.isInitialLoad;

      return Skeletonizer(
        enabled: showSkeleton,
        child: ListView.builder(
          itemCount: showSkeleton ? 5 : state.tasks.length,
          itemBuilder: (context, index) {
            final task = showSkeleton
              ? TaskModel.fake()  // Fake data for skeleton
              : state.tasks[index];

            return TaskCard(task: task);
          },
        ),
      );
    },
  );
}
```

### Where to Add Skeletons

**Priority 1 (High Impact):**
- ✅ Task lists (today tasks, all tasks)
- ✅ Assignment lists
- ✅ Notification list
- ✅ Statistics page

**Priority 2 (Medium Impact):**
- User profile page
- Task detail page
- Group list

### Creating Fake Data for Skeletons

Add static fake constructors to models:
```dart
// Example: TaskModel.fake()
class TaskModel {
  // ... existing code

  factory TaskModel.fake() {
    return TaskModel(
      id: 'skeleton',
      title: 'عنوان المهمة',
      description: 'وصف المهمة يتم تحميله...',
      labelIds: [],
      createdBy: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // ... other fields
    );
  }
}
```

---

## 6. Checklist for New Widgets

Use this checklist when creating new widgets:

- [ ] Is the widget stateless and can it be const? → Add `const`
- [ ] Does it use BlocBuilder? → Add `buildWhen`
- [ ] Does it show lists? → Add keys to items
- [ ] Is it expensive to paint? → Consider `RepaintBoundary`
- [ ] Does it load data? → Add skeleton loader
- [ ] Uses EdgeInsets/SizedBox? → Make them const
- [ ] Has static text? → Make it const

---

## 7. Performance Profiling

### Flutter DevTools

1. **Performance View**
   ```bash
   flutter run --profile
   # Open DevTools → Performance tab
   ```

2. **Widget Rebuild Profiler**
   ```bash
   flutter run --profile
   # Open DevTools → Performance → Track Rebuilds
   ```

3. **Memory View**
   ```bash
   flutter run --profile
   # Open DevTools → Memory tab
   ```

### Measuring Improvements

**Before optimization:**
```bash
flutter drive --target=test_driver/perf_test.dart --profile
```

**After optimization:**
```bash
flutter drive --target=test_driver/perf_test.dart --profile
# Compare frame render times
```

---

## 8. Code Examples

### Optimized Task Card Widget

```dart
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final TaskModel task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),  // ✅ Const
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),  // ✅ Const
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),  // ✅ Const
              _buildLabels(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabels() {
    return Wrap(
      spacing: 8,
      children: task.labels.map((label) =>
        Chip(
          label: Text(label.name),
          backgroundColor: Color(label.color),
        ),
      ).toList(),
    );
  }
}
```

### Optimized Task List with Skeleton

```dart
class TaskListWidget extends StatelessWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayTasksBloc, TodayTasksState>(
      buildWhen: (previous, current) =>
        previous.tasks != current.tasks ||
        previous.loadingState != current.loadingState,
      builder: (context, state) {
        final showSkeleton = state.loadingState.isInitialLoad;
        final itemCount = showSkeleton ? 5 : state.tasks.length;

        return Skeletonizer(
          enabled: showSkeleton,
          child: ListView.separated(
            itemCount: itemCount,
            separatorBuilder: (_, __) => const Divider(),  // ✅ Const
            itemBuilder: (context, index) {
              final task = showSkeleton
                ? TaskModel.fake()
                : state.tasks[index];

              return TaskCard(
                key: ValueKey(task.id),  // ✅ Key for list
                task: task,
                onTap: showSkeleton ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailPage(taskId: task.id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
```

---

## 9. Common Mistakes to Avoid

### ❌ Mistake 1: Creating new objects in build
```dart
// BAD
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16),  // ❌ New object every build
  );
}

// GOOD
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),  // ✅ Const
  );
}
```

### ❌ Mistake 2: Rebuilding entire tree unnecessarily
```dart
// BAD
BlocBuilder<AppBloc, AppState>(
  builder: (context, state) {
    return Scaffold(
      appBar: AppBar(...),  // ❌ Rebuilds even if unchanged
      body: ListView(...),
    );
  },
)

// GOOD
Scaffold(
  appBar: AppBar(...),  // ✅ Built once
  body: BlocBuilder<AppBloc, AppState>(
    buildWhen: (previous, current) => previous.data != current.data,
    builder: (context, state) {
      return ListView(...);  // ✅ Only body rebuilds
    },
  ),
)
```

### ❌ Mistake 3: Forgetting keys in stateful widgets
```dart
// BAD
ListView.builder(
  itemBuilder: (context, index) {
    return StatefulTaskCard(task: tasks[index]);  // ❌ Loses state
  },
)

// GOOD
ListView.builder(
  itemBuilder: (context, index) {
    final task = tasks[index];
    return StatefulTaskCard(
      key: ValueKey(task.id),  // ✅ Preserves state
      task: task,
    );
  },
)
```

---

## 10. Quick Wins (Low Effort, High Impact)

Prioritize these optimizations:

1. **Add const to static widgets** (30 min)
   - Search for `EdgeInsets.`, `SizedBox`, `Text`, `Icon`
   - Add `const` keyword

2. **Add buildWhen to BlocBuilders** (1 hour)
   - Find all `BlocBuilder` usages
   - Add `buildWhen` conditions

3. **Add skeleton to main lists** (1 hour)
   - Wrap ListViews in Skeletonizer
   - Use existing `isLoading` state

4. **Add keys to list items** (30 min)
   - Find all `ListView.builder`
   - Add `ValueKey` to items

---

## 📊 Expected Performance Gains

After implementing these optimizations:

- **Frame render time:** 15-25% reduction
- **Memory usage:** 10-15% reduction
- **Battery consumption:** 5-10% improvement
- **Perceived performance:** Significantly better UX

---

## 📚 Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter Performance Profiling](https://docs.flutter.dev/perf/ui-performance)
- [Skeletonizer Package](https://pub.dev/packages/skeletonizer)
- [BLoC Library Best Practices](https://bloclibrary.dev/#/architecture)

---

**Last Updated:** November 24, 2025
**Maintainer:** Development Team
