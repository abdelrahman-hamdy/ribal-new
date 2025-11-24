/// Firebase collection and field names
abstract final class FirebaseConstants {
  // ============================================
  // COLLECTION NAMES
  // ============================================

  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String assignmentsCollection = 'assignments';
  static const String groupsCollection = 'groups';
  static const String labelsCollection = 'labels';
  static const String whitelistCollection = 'whitelist';
  static const String invitationsCollection = 'invitations';
  static const String notificationsCollection = 'notifications';
  static const String settingsCollection = 'settings';

  // ============================================
  // DOCUMENT IDS
  // ============================================

  static const String globalSettingsDoc = 'global';

  // ============================================
  // USER FIELDS
  // ============================================

  static const String userFirstName = 'firstName';
  static const String userLastName = 'lastName';
  static const String userEmail = 'email';
  static const String userRole = 'role';
  static const String userGroupId = 'groupId';
  static const String userManagedGroupIds = 'managedGroupIds';
  static const String userCanAssignToAll = 'canAssignToAll';
  static const String userFcmTokens = 'fcmTokens';
  static const String userCreatedAt = 'createdAt';
  static const String userUpdatedAt = 'updatedAt';

  // ============================================
  // TASK FIELDS
  // ============================================

  static const String taskTitle = 'title';
  static const String taskDescription = 'description';
  static const String taskLabelIds = 'labelIds';
  static const String taskAttachmentUrl = 'attachmentUrl';
  static const String taskIsRecurring = 'isRecurring';
  static const String taskIsActive = 'isActive';
  static const String taskIsArchived = 'isArchived';
  static const String taskAttachmentRequired = 'attachmentRequired';
  static const String taskAssigneeSelection = 'assigneeSelection';
  static const String taskSelectedGroupIds = 'selectedGroupIds';
  static const String taskSelectedUserIds = 'selectedUserIds';
  static const String taskCreatedBy = 'createdBy';
  static const String taskCreatedAt = 'createdAt';
  static const String taskUpdatedAt = 'updatedAt';

  // ============================================
  // ASSIGNMENT FIELDS
  // ============================================

  static const String assignmentTaskId = 'taskId';
  static const String assignmentUserId = 'userId';
  static const String assignmentStatus = 'status';
  static const String assignmentApologizeMessage = 'apologizeMessage';
  static const String assignmentCompletedAt = 'completedAt';
  static const String assignmentApologizedAt = 'apologizedAt';
  static const String assignmentMarkedDoneBy = 'markedDoneBy';
  static const String assignmentAttachmentUrl = 'attachmentUrl';
  static const String assignmentScheduledDate = 'scheduledDate';
  static const String assignmentCreatedAt = 'createdAt';

  // ============================================
  // GROUP FIELDS
  // ============================================

  static const String groupName = 'name';
  static const String groupCreatedBy = 'createdBy';
  static const String groupCreatedAt = 'createdAt';

  // ============================================
  // LABEL FIELDS
  // ============================================

  static const String labelName = 'name';
  static const String labelColor = 'color';
  static const String labelIsActive = 'isActive';
  static const String labelCreatedBy = 'createdBy';
  static const String labelCreatedAt = 'createdAt';

  // ============================================
  // WHITELIST FIELDS
  // ============================================

  static const String whitelistEmail = 'email';
  static const String whitelistRole = 'role';
  static const String whitelistCreatedBy = 'createdBy';
  static const String whitelistCreatedAt = 'createdAt';

  // ============================================
  // INVITATION FIELDS
  // ============================================

  static const String invitationCode = 'code';
  static const String invitationRole = 'role';
  static const String invitationUsed = 'used';
  static const String invitationUsedBy = 'usedBy';
  static const String invitationUsedAt = 'usedAt';
  static const String invitationCreatedBy = 'createdBy';
  static const String invitationCreatedAt = 'createdAt';

  // ============================================
  // NOTIFICATION FIELDS
  // ============================================

  static const String notificationUserId = 'userId';
  static const String notificationType = 'type';
  static const String notificationTitle = 'title';
  static const String notificationBody = 'body';
  static const String notificationIconName = 'iconName';
  static const String notificationIconColor = 'iconColor';
  static const String notificationDeepLink = 'deepLink';
  static const String notificationIsRead = 'isRead';
  static const String notificationIsSeen = 'isSeen';
  static const String notificationCreatedAt = 'createdAt';

  // ============================================
  // SETTINGS FIELDS
  // ============================================

  static const String settingsRecurringTaskTime = 'recurringTaskTime';
  static const String settingsTaskDeadline = 'taskDeadline';

  // ============================================
  // STORAGE PATHS
  // ============================================

  static const String taskAttachmentsPath = 'task_attachments';
  static const String userAvatarsPath = 'user_avatars';
}
