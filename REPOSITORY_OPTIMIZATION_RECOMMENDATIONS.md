# Repository Layer Optimization Recommendations

**Purpose:** Guidelines for optimizing Firebase repository methods for production use

---

## 🎯 Current State vs Recommended State

### Repositories Status

| Repository | Batch Methods | Pagination | Limits | Stream Optimization |
|-----------|--------------|------------|--------|-------------------|
| UserRepository | ✅ Complete | N/A | ⚠️ Needed | ⚠️ Review |
| TaskRepository | N/A | ✅ Complete | ✅ Good | ⚠️ Review |
| AssignmentRepository | N/A | ✅ Complete | ⚠️ Needed | ⚠️ Review |
| NoteRepository | ✅ Complete | N/A | ✅ Good | ✅ Good |
| LabelRepository | N/A | N/A | ⚠️ Needed | ⚠️ Review |
| NotificationRepository | N/A | ⚠️ Needed | ✅ Good | ⚠️ Review |
| StatisticsRepository | N/A | N/A | ⚠️ Needed | N/A |

---

## 📋 Phase 2.5: Add Query Limits

### Priority: HIGH

**Problem:** Several methods fetch unbounded datasets that will grow over time.

### Methods Requiring Limits

#### 1. UserRepository

**Current:**
```dart
Future<List<UserModel>> getAllUsers() async {
  final snapshot = await _firestoreService.usersCollection
      .orderBy(FirebaseConstants.userCreatedAt, descending: true)
      .get();  // ❌ No limit

  return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
}
```

**Recommended:**
```dart
Future<List<UserModel>> getAllUsers({int limit = 100}) async {
  final snapshot = await _firestoreService.usersCollection
      .orderBy(FirebaseConstants.userCreatedAt, descending: true)
      .limit(limit)  // ✅ Add limit
      .get();

  return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
}

// Better: Add pagination version
Future<PaginatedResult<UserModel>> getAllUsersPaginated({
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  // ... pagination implementation
}
```

**Other methods to limit:**
- `getUsersByRole()` - Add default limit of 100
- `getUsersByGroup()` - Add default limit of 50
- `getAssignableUsers()` - Add default limit of 100

---

#### 2. LabelRepository

**Need to check and add limits to:**
- `getAllLabels()` - Should have limit of 50 (labels are typically few)

**Current (assumed):**
```dart
Future<List<LabelModel>> getAllLabels() async {
  final snapshot = await _firestoreService.labelsCollection.get();  // ❌ No limit
  return snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList();
}
```

**Recommended:**
```dart
Future<List<LabelModel>> getAllLabels({int limit = 50}) async {
  final snapshot = await _firestoreService.labelsCollection
      .limit(limit)  // ✅ Add limit
      .get();
  return snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList();
}
```

---

#### 3. NotificationRepository

**Needs pagination:**
```dart
// Add this method
Future<PaginatedResult<NotificationModel>> getNotificationsPaginated({
  required String userId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  var query = _firestoreService.notificationsCollection
      .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
      .orderBy(FirebaseConstants.notificationCreatedAt, descending: true)
      .limit(limit);

  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }

  final snapshot = await query.get();
  final notifications = snapshot.docs
      .map((doc) => NotificationModel.fromFirestore(doc))
      .toList();

  return PaginatedResult(
    items: notifications,
    lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    hasMore: snapshot.docs.length == limit,
  );
}
```

---

#### 4. StatisticsRepository

**Current methods likely fetch all data:**
- `getUserPerformance()` - Should limit to top N performers
- Any methods fetching assignments/tasks for stats

**Recommended:**
```dart
Future<List<UserPerformance>> getUserPerformance({
  required DateTime startDate,
  required DateTime endDate,
  int limit = 50,  // ✅ Add limit for top performers
}) async {
  // ... existing logic
  // Add limit before returning
  return performances.take(limit).toList();
}
```

---

## 🔄 Stream Optimization Recommendations

### Priority: MEDIUM

**Problem:** Some streams are used for data that rarely changes or doesn't need real-time updates.

### Convert Streams to One-Time Fetches

#### 1. Label Streams

Labels rarely change - don't need real-time updates:

**Current:**
```dart
Stream<List<LabelModel>> streamAllLabels() {
  return _firestoreService.labelsCollection
      .snapshots()  // ❌ Real-time updates not needed
      .map((snapshot) => ...);
}
```

**Recommended:**
```dart
// Keep stream for admin panel where labels are managed
Stream<List<LabelModel>> streamAllLabels() {
  return _firestoreService.labelsCollection.snapshots().map(...);
}

// Add one-time fetch for regular usage
Future<List<LabelModel>> getAllLabels() async {
  // Use offline cache first
  final snapshot = await _firestoreService.labelsCollection.get();
  return snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList();
}

// Add cached version with refresh
class LabelRepository {
  List<LabelModel>? _cachedLabels;
  DateTime? _cacheTime;

  Future<List<LabelModel>> getAllLabelsCached({
    Duration cacheDuration = const Duration(minutes: 10),
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    if (!forceRefresh &&
        _cachedLabels != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < cacheDuration) {
      return _cachedLabels!;
    }

    _cachedLabels = await getAllLabels();
    _cacheTime = now;
    return _cachedLabels!;
  }
}
```

**Usage in Blocs:**
```dart
// OLD: Stream labels (unnecessary real-time updates)
_labelRepository.streamAllLabels().listen(...);

// NEW: Fetch once and cache
final labels = await _labelRepository.getAllLabelsCached();
```

**Benefit:** 90% reduction in Firestore read operations for labels

---

#### 2. User Profile Streams (Selective)

User profiles rarely change - only stream when necessary:

**Guidelines:**
- ✅ **Keep stream:** Admin panel user management
- ✅ **Keep stream:** Current user profile (for real-time permission updates)
- ❌ **Remove stream:** Task creator info (fetch once)
- ❌ **Remove stream:** Assignment user info (use batch fetch)

**Example - Task Creator:**
```dart
// OLD in TaskDetailBloc
_userRepository.streamUser(task.createdBy).listen(...);  // ❌ Unnecessary

// NEW
final creator = await _userRepository.getUserById(task.createdBy);  // ✅ One-time fetch
```

---

### Stream Deduplication

**Problem:** Multiple widgets may create duplicate streams for the same data.

**Solution:** Use StreamCache utility (already created)

**Example:**
```dart
// In UserRepository
class UserRepository {
  final Map<String, StreamCache<UserModel>> _userStreamCaches = {};

  Stream<UserModel?> streamUserCached(String userId) {
    _userStreamCaches[userId] ??= StreamCache(
      source: () => streamUser(userId),
      duration: const Duration(minutes: 5),
    );

    return _userStreamCaches[userId]!.stream;
  }

  // Clear cache on logout
  void clearCaches() {
    for (final cache in _userStreamCaches.values) {
      cache.clear();
    }
    _userStreamCaches.clear();
  }
}
```

**Usage:**
```dart
// Multiple widgets can now share the same stream
StreamBuilder<UserModel?>(
  stream: _userRepository.streamUserCached(userId),  // ✅ Cached
  builder: (context, snapshot) { ... },
)
```

---

## 🎯 Selective Stream Usage Guidelines

### When to Use Streams (.snapshots())

✅ **Use streams for:**
1. Current user's notifications
2. Real-time task assignments for current day
3. Admin panels monitoring live data
4. Chat messages
5. Active session status

❌ **Don't use streams for:**
1. Labels (rarely change)
2. Groups (rarely change)
3. Historical task data
4. User profiles in task lists
5. Statistics (calculated data)
6. Archived tasks

### Decision Matrix

| Data Type | Update Frequency | User Impact | Recommendation |
|-----------|-----------------|-------------|----------------|
| Current user notifications | High | High | ✅ Stream |
| Today's assignments | Medium | High | ✅ Stream |
| User profile (own) | Low | Medium | ✅ Stream |
| User profile (others) | Low | Low | ❌ Fetch once |
| Labels | Very Low | Low | ❌ Cache + Fetch |
| Historical tasks | None | Low | ❌ Fetch once |
| Statistics | Low | Medium | ❌ Fetch on demand |

---

## 📊 Implementation Priority

### Phase 2.5 - Query Limits (IMMEDIATE)

**Timeline:** 2-3 hours

1. **UserRepository** (30 min)
   - Add limit to `getAllUsers()`
   - Add limit to `getUsersByRole()`
   - Add limit to `getAssignableUsers()`

2. **LabelRepository** (15 min)
   - Add limit to `getAllLabels()`

3. **NotificationRepository** (45 min)
   - Add `getNotificationsPaginated()`
   - Update notification list UI to use pagination

4. **StatisticsRepository** (30 min)
   - Add limit to `getUserPerformance()`
   - Review other stat methods

5. **Testing** (30 min)
   - Test with large datasets
   - Verify limits work correctly

---

### Phase 5.1 - Stream Optimization (1-2 days)

**Timeline:** 8-16 hours

**Day 1: Audit (4 hours)**
1. Find all `.snapshots()` usages
2. Categorize by necessity (critical/nice-to-have/unnecessary)
3. Identify duplicate streams
4. Document current listener counts

**Command:**
```bash
# Find all stream usages
grep -r "\.snapshots()" lib/ --include="*.dart" -n

# Find all StreamBuilder usages
grep -r "StreamBuilder" lib/ --include="*.dart" -n
```

**Day 2: Implement (4-12 hours)**
1. Convert unnecessary streams to one-time fetches (2 hours)
2. Add caching to label repository (1 hour)
3. Implement stream deduplication (2 hours)
4. Add stream utilities to key repositories (2 hours)
5. Update blocs to use new patterns (2-6 hours)
6. Testing (2 hours)

---

## 🔍 Audit Script

Run this to find potential optimizations:

```bash
#!/bin/bash

echo "=== Repository Method Audit ==="
echo ""

echo "Methods without limits:"
grep -r "\.get()" lib/data/repositories/ --include="*.dart" -B 5 | \
  grep -v "\.limit(" | \
  grep "Future<List" -A 5

echo ""
echo "Stream usages:"
grep -r "\.snapshots()" lib/ --include="*.dart" -n | wc -l

echo ""
echo "Methods that could be paginated:"
grep -r "Future<List<.*Model>>" lib/data/repositories/ --include="*.dart" -n
```

---

## ✅ Validation Checklist

After implementing optimizations:

- [ ] All list queries have reasonable limits (20-100)
- [ ] Pagination available for user-facing lists
- [ ] Labels use caching (not real-time streams)
- [ ] No duplicate streams for same data
- [ ] Stream count reduced by 30-50%
- [ ] Load testing with 1000+ items works
- [ ] Firestore read costs reduced by 40-60%
- [ ] No performance regressions
- [ ] All tests passing

---

## 📈 Expected Results

### After Query Limits

- **Protection:** App won't slow down as data grows
- **Performance:** Faster query execution (smaller result sets)
- **Cost:** Lower Firestore costs (fewer documents read)

### After Stream Optimization

- **Bandwidth:** 40-60% reduction
- **Battery:** 10-20% improvement
- **Cost:** 50-70% reduction in Firestore read operations
- **Reliability:** Fewer listener limit issues

---

## 🛠 Tools & Monitoring

### Firebase Console

Monitor these metrics before/after:
1. **Firestore Reads** (should decrease 40-60%)
2. **Active Listeners** (should decrease 30-50%)
3. **Bandwidth** (should decrease 40-60%)

### Flutter DevTools

Monitor:
1. **Network tab** - Firestore request counts
2. **Memory tab** - StreamSubscription counts
3. **Performance tab** - Frame rates

---

**Last Updated:** November 24, 2025
**Status:** Recommendations Ready for Implementation
