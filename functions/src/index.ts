import { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import * as crypto from "crypto";

// Cloudinary secrets (set via: firebase functions:secrets:set CLOUDINARY_API_SECRET)
const cloudinaryApiSecret = defineSecret("CLOUDINARY_API_SECRET");

initializeApp();

const db = getFirestore();

// Types
interface Task {
  id: string;
  title: string;
  description: string;
  labelIds: string[];
  attachmentUrl?: string;
  isRecurring: boolean;
  isActive: boolean;
  isArchived: boolean;
  assigneeSelection: "all" | "groups" | "custom";
  selectedGroupIds: string[];
  selectedUserIds: string[];
  createdBy: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

interface Assignment {
  taskId: string;
  userId: string;
  status: "pending" | "completed" | "apologized";
  apologizeMessage?: string;
  completedAt?: Timestamp;
  apologizedAt?: Timestamp;
  markedDoneBy?: string;
  scheduledDate: Timestamp;
  createdAt: Timestamp;
  // Denormalized fields for performance (avoid extra fetches in app)
  taskTitle?: string;
  userName?: string;
}

interface Settings {
  recurringTaskTime: string; // HH:mm format, e.g., "08:00"
  taskDeadline: string; // HH:mm format, e.g., "20:00"
}

// Default settings
const DEFAULT_SETTINGS: Settings = {
  recurringTaskTime: "08:00",
  taskDeadline: "20:00",
};

/**
 * Get settings from Firestore
 */
async function getSettings(): Promise<Settings> {
  try {
    const settingsDoc = await db.collection("settings").doc("global").get();
    if (settingsDoc.exists) {
      const data = settingsDoc.data();
      return {
        recurringTaskTime: data?.recurringTaskTime || DEFAULT_SETTINGS.recurringTaskTime,
        taskDeadline: data?.taskDeadline || DEFAULT_SETTINGS.taskDeadline,
      };
    }
  } catch (error) {
    console.error("Error fetching settings:", error);
  }
  return DEFAULT_SETTINGS;
}

/**
 * Parse time string (HH:mm) to hours and minutes
 */
function parseTime(timeStr: string): { hours: number; minutes: number } {
  const [hours, minutes] = timeStr.split(":").map(Number);
  return { hours, minutes };
}

/**
 * Get today's date at a specific time (in Riyadh timezone)
 */
function getTodayAtTime(timeStr: string): Date {
  const { hours, minutes } = parseTime(timeStr);
  const now = new Date();
  // Create date in Riyadh timezone (UTC+3)
  const riyadhOffset = 3 * 60; // minutes
  const utcNow = now.getTime() + now.getTimezoneOffset() * 60000;
  const riyadhNow = new Date(utcNow + riyadhOffset * 60000);

  return new Date(
    riyadhNow.getFullYear(),
    riyadhNow.getMonth(),
    riyadhNow.getDate(),
    hours,
    minutes,
    0,
    0
  );
}

/**
 * Check if current time is after the recurring task time
 */
function isAfterRecurringTime(settings: Settings): boolean {
  const now = new Date();
  const riyadhOffset = 3 * 60;
  const utcNow = now.getTime() + now.getTimezoneOffset() * 60000;
  const riyadhNow = new Date(utcNow + riyadhOffset * 60000);

  const recurringTime = getTodayAtTime(settings.recurringTaskTime);
  return riyadhNow >= recurringTime;
}

/**
 * Check if current time is before the deadline
 */
function isBeforeDeadline(settings: Settings): boolean {
  const now = new Date();
  const riyadhOffset = 3 * 60;
  const utcNow = now.getTime() + now.getTimezoneOffset() * 60000;
  const riyadhNow = new Date(utcNow + riyadhOffset * 60000);

  const deadlineTime = getTodayAtTime(settings.taskDeadline);
  return riyadhNow < deadlineTime;
}

/**
 * Get users to assign based on task settings and creator's role
 */
async function getUsersToAssign(task: Task): Promise<string[]> {
  const userIds: string[] = [];

  switch (task.assigneeSelection) {
    case "all": {
      // Get the creator's role to determine who to assign to
      const creatorDoc = await db.collection("users").doc(task.createdBy).get();
      const creatorRole = creatorDoc.exists ? creatorDoc.data()?.role : null;

      if (creatorRole === "admin") {
        // Admins: assign to all managers and employees
        const usersSnapshot = await db
          .collection("users")
          .where("role", "in", ["manager", "employee"])
          .get();
        usersSnapshot.forEach((doc) => userIds.push(doc.id));
      } else if (creatorRole === "manager") {
        // Managers: assign to employees only (within their privilege scope)
        const creatorData = creatorDoc.data();
        const canAssignToAll = creatorData?.canAssignToAll === true;
        const managedGroupIds: string[] = creatorData?.managedGroupIds || [];

        if (canAssignToAll) {
          // Manager with canAssignToAll can assign to all employees
          const usersSnapshot = await db
            .collection("users")
            .where("role", "==", "employee")
            .get();
          usersSnapshot.forEach((doc) => userIds.push(doc.id));
        } else if (managedGroupIds.length > 0) {
          // Manager can only assign to employees in their managed groups
          // Firestore 'in' query is limited to 30 items, so we need to chunk
          for (let i = 0; i < managedGroupIds.length; i += 10) {
            const chunk = managedGroupIds.slice(i, i + 10);
            const usersSnapshot = await db
              .collection("users")
              .where("groupId", "in", chunk)
              .where("role", "==", "employee")
              .get();
            usersSnapshot.forEach((doc) => {
              if (!userIds.includes(doc.id)) {
                userIds.push(doc.id);
              }
            });
          }
        }
      } else {
        // Fallback: only employees (original behavior)
        const usersSnapshot = await db
          .collection("users")
          .where("role", "==", "employee")
          .get();
        usersSnapshot.forEach((doc) => userIds.push(doc.id));
      }
      break;
    }
    case "groups": {
      // Get users in selected groups
      if (task.selectedGroupIds.length > 0) {
        const usersSnapshot = await db
          .collection("users")
          .where("groupId", "in", task.selectedGroupIds)
          .get();
        usersSnapshot.forEach((doc) => userIds.push(doc.id));
      }
      break;
    }
    case "custom": {
      // Use selected user IDs directly
      userIds.push(...task.selectedUserIds);
      break;
    }
  }

  return userIds;
}

/**
 * Create assignments for a task on a specific date
 */
async function createAssignmentsForTask(
  taskId: string,
  task: Task,
  date: Date
): Promise<number> {
  const userIds = await getUsersToAssign(task);

  if (userIds.length === 0) {
    console.log(`No users to assign for task ${taskId}`);
    return 0;
  }

  // Create date at start of day (for scheduledDate)
  const scheduledDate = new Date(date);
  scheduledDate.setHours(0, 0, 0, 0);

  // Check for existing assignments on this date
  const existingSnapshot = await db
    .collection("assignments")
    .where("taskId", "==", taskId)
    .where(
      "scheduledDate",
      ">=",
      Timestamp.fromDate(scheduledDate)
    )
    .where(
      "scheduledDate",
      "<",
      Timestamp.fromDate(
        new Date(scheduledDate.getTime() + 24 * 60 * 60 * 1000)
      )
    )
    .get();

  const existingUserIds = new Set(
    existingSnapshot.docs.map((doc) => doc.data().userId)
  );

  // Filter to only users who don't have assignments yet
  const newUserIds = userIds.filter((id) => !existingUserIds.has(id));

  if (newUserIds.length === 0) {
    console.log(`All users already have assignments for task ${taskId}`);
    return 0;
  }

  // Fetch user names for denormalization (in batches of 10)
  const userNames: Map<string, string> = new Map();
  for (let i = 0; i < newUserIds.length; i += 10) {
    const batch = newUserIds.slice(i, i + 10);
    const usersSnapshot = await db
      .collection("users")
      .where("__name__", "in", batch)
      .get();
    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      const firstName = data.firstName || data.firstname || "";
      const lastName = data.lastName || data.lastname || "";
      userNames.set(doc.id, `${firstName} ${lastName}`.trim() || "Unknown");
    });
  }

  // Create assignments for users who don't have one yet
  const batch = db.batch();
  let createdCount = 0;
  const now = Timestamp.now();
  const assignmentRefs: Array<{ ref: FirebaseFirestore.DocumentReference; userId: string }> = [];

  for (const userId of newUserIds) {
    const assignmentRef = db.collection("assignments").doc();
    const assignment: Assignment = {
      taskId,
      userId,
      status: "pending",
      scheduledDate: Timestamp.fromDate(scheduledDate),
      createdAt: now,
      // Denormalized fields for performance
      taskTitle: task.title,
      userName: userNames.get(userId) || "Unknown",
    };
    batch.set(assignmentRef, assignment);
    assignmentRefs.push({ ref: assignmentRef, userId });
    createdCount++;
  }

  if (createdCount > 0) {
    await batch.commit();
    console.log(
      `Created ${createdCount} assignments for task ${taskId} on ${scheduledDate.toISOString()}`
    );

    // Create notifications for task assignments (with assignment IDs)
    const notificationBatch = db.batch();
    for (const { ref, userId } of assignmentRefs) {
      const notificationRef = db.collection("notifications").doc();
      notificationBatch.set(notificationRef, {
        userId,
        type: "taskAssigned",
        title: "مهمة جديدة",
        body: `تم تعيين مهمة جديدة لك: ${task.title}`,
        iconName: "task_add",
        iconColor: "#2563EB",
        deepLink: `/assignments/${ref.id}`, // Link to assignment detail
        isSeen: false,
        isRead: false,
        createdAt: now,
      });
    }
    await notificationBatch.commit();
    console.log(`Created ${assignmentRefs.length} task assignment notifications`);
  }

  return createdCount;
}

/**
 * Trigger: When a new task is created
 * Creates initial assignments for the task
 */
export const onTaskCreated = onDocumentCreated("tasks/{taskId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }

  const taskId = event.params.taskId;
  const task = { id: taskId, ...snapshot.data() } as Task;

  console.log(`Task created: ${taskId} - ${task.title}`);

  // Only create assignments for active, non-archived tasks
  if (!task.isActive || task.isArchived) {
    console.log(`Task ${taskId} is not active or is archived, skipping`);
    return;
  }

  // Get settings
  const settings = await getSettings();

  // For recurring tasks, check if we're after the recurring time
  if (task.isRecurring && !isAfterRecurringTime(settings)) {
    console.log(`Task ${taskId} is recurring but it's before recurring time (${settings.recurringTaskTime}), skipping`);
    return;
  }

  // Check if we're before the deadline
  if (!isBeforeDeadline(settings)) {
    console.log(`Task ${taskId}: Current time is past the deadline (${settings.taskDeadline}), skipping`);
    return;
  }

  const today = new Date();
  const createdCount = await createAssignmentsForTask(taskId, task, today);

  console.log(`Created ${createdCount} initial assignments for task ${taskId}`);
});

/**
 * Trigger: When a task is updated
 * Handles reactivation of paused tasks
 */
export const onTaskUpdated = onDocumentUpdated("tasks/{taskId}", async (event) => {
  const change = event.data;
  if (!change) {
    console.log("No data associated with the event");
    return;
  }

  const taskId = event.params.taskId;
  const before = change.before.data() as Task;
  const after = { id: taskId, ...change.after.data() } as Task;

  // Get settings
  const settings = await getSettings();

  // If task was reactivated (became active from inactive)
  if (!before.isActive && after.isActive && !after.isArchived) {
    console.log(`Task ${taskId} was reactivated`);

    // For recurring tasks, check if we're after the recurring time
    if (after.isRecurring && !isAfterRecurringTime(settings)) {
      console.log(`Task ${taskId} is recurring but it's before recurring time (${settings.recurringTaskTime}), will be processed by scheduler`);
      return;
    }

    // Check if we're before the deadline
    if (!isBeforeDeadline(settings)) {
      console.log(`Task ${taskId}: Current time is past the deadline (${settings.taskDeadline}), skipping for today`);
      return;
    }

    const today = new Date();
    await createAssignmentsForTask(taskId, after, today);
  }

  // If task was unarchived
  if (before.isArchived && !after.isArchived && after.isActive) {
    console.log(`Task ${taskId} was unarchived`);

    // For recurring tasks, check if we're after the recurring time
    if (after.isRecurring && !isAfterRecurringTime(settings)) {
      console.log(`Task ${taskId} is recurring but it's before recurring time (${settings.recurringTaskTime}), will be processed by scheduler`);
      return;
    }

    // Check if we're before the deadline
    if (!isBeforeDeadline(settings)) {
      console.log(`Task ${taskId}: Current time is past the deadline (${settings.taskDeadline}), skipping for today`);
      return;
    }

    const today = new Date();
    await createAssignmentsForTask(taskId, after, today);
  }
});

/**
 * Scheduled: Generate assignments for active recurring tasks
 * Runs every 5 minutes to ensure assignments are created for all active tasks
 * Only creates assignments during the valid time window
 */
export const generateAssignments = onSchedule({
  schedule: "every 5 minutes",
  timeZone: "Asia/Riyadh",
}, async () => {
  console.log("Starting assignment generation check...");

  // Get settings
  const settings = await getSettings();

  // Check if we're within the valid time window
  if (!isAfterRecurringTime(settings)) {
    console.log(`Current time is before recurring time (${settings.recurringTaskTime}), skipping assignment generation`);
    return;
  }

  if (!isBeforeDeadline(settings)) {
    console.log(`Current time is past the deadline (${settings.taskDeadline}), skipping assignment generation`);
    return;
  }

  console.log(`Time window valid: after ${settings.recurringTaskTime}, before ${settings.taskDeadline}`);

  // Get all active recurring tasks
  const tasksSnapshot = await db
    .collection("tasks")
    .where("isActive", "==", true)
    .where("isArchived", "==", false)
    .where("isRecurring", "==", true)
    .get();

  const today = new Date();
  let totalCreated = 0;

  for (const doc of tasksSnapshot.docs) {
    const task = { id: doc.id, ...doc.data() } as Task;
    try {
      // Create assignments if none exist today
      const count = await createAssignmentsForTask(doc.id, task, today);
      totalCreated += count;
    } catch (error) {
      console.error(`Error creating assignments for task ${doc.id}:`, error);
    }
  }

  console.log(
    `Assignment generation complete. Created ${totalCreated} new assignments for ${tasksSnapshot.size} active recurring tasks.`
  );
});

/**
 * HTTP Trigger: Manually generate assignments for a specific task
 * Useful for testing or manual assignment creation
 */
export const manualGenerateAssignments = onCall(async (request) => {
  // Check if user is authenticated
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { taskId } = request.data;
  if (!taskId) {
    throw new HttpsError(
      "invalid-argument",
      "taskId is required"
    );
  }

  // Get the task
  const taskDoc = await db.collection("tasks").doc(taskId).get();
  if (!taskDoc.exists) {
    throw new HttpsError("not-found", "Task not found");
  }

  const task = { id: taskId, ...taskDoc.data() } as Task;

  // Check if task is active
  if (!task.isActive || task.isArchived) {
    throw new HttpsError(
      "failed-precondition",
      "Task is not active or is archived"
    );
  }

  // Get settings and check time window
  const settings = await getSettings();

  if (!isBeforeDeadline(settings)) {
    throw new HttpsError(
      "failed-precondition",
      `Cannot create assignments after the deadline (${settings.taskDeadline})`
    );
  }

  const today = new Date();
  const createdCount = await createAssignmentsForTask(taskId, task, today);

  return {
    success: true,
    message: `Created ${createdCount} assignments for task ${taskId}`,
    count: createdCount,
  };
});

/**
 * HTTP Trigger: Generate assignments for all active tasks
 * Useful for manual trigger of assignment generation
 */
export const manualGenerateAllAssignments = onCall(async (request) => {
  // Check if user is authenticated
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  // Get user role
  const userDoc = await db.collection("users").doc(request.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only admins can trigger this function"
    );
  }

  // Get settings and check time window
  const settings = await getSettings();

  if (!isBeforeDeadline(settings)) {
    throw new HttpsError(
      "failed-precondition",
      `Cannot create assignments after the deadline (${settings.taskDeadline})`
    );
  }

  console.log("Manual trigger: Starting assignment generation...");
  console.log(`Time settings: recurring=${settings.recurringTaskTime}, deadline=${settings.taskDeadline}`);

  // Get all active tasks (both recurring and one-time)
  const tasksSnapshot = await db
    .collection("tasks")
    .where("isActive", "==", true)
    .where("isArchived", "==", false)
    .get();

  const today = new Date();
  let totalCreated = 0;
  const results: { taskId: string; taskTitle: string; count: number }[] = [];

  for (const doc of tasksSnapshot.docs) {
    const task = { id: doc.id, ...doc.data() } as Task;
    try {
      const count = await createAssignmentsForTask(doc.id, task, today);
      totalCreated += count;
      results.push({
        taskId: doc.id,
        taskTitle: task.title,
        count,
      });
    } catch (error) {
      console.error(`Error creating assignments for task ${doc.id}:`, error);
    }
  }

  return {
    success: true,
    message: `Created ${totalCreated} assignments for ${tasksSnapshot.size} tasks`,
    totalCount: totalCreated,
    taskCount: tasksSnapshot.size,
    results,
  };
});

/**
 * Trigger: When a task is manually deleted by user
 * Deletes all assignments associated with the task.
 * This ensures fairness - if a task is manually deleted, it shouldn't count for anyone.
 */
export const onTaskDeleted = onDocumentDeleted("tasks/{taskId}", async (event) => {
  const taskId = event.params.taskId;

  // Check if this is a scheduled deletion (marker exists)
  const markerDoc = await db.collection("_scheduledDeletions").doc(taskId).get();

  if (markerDoc.exists) {
    // This is a scheduled deletion - preserve assignments, just clean up the marker
    await markerDoc.ref.delete();
    console.log(`Task ${taskId} was deleted by scheduler - assignments preserved for statistics`);
    return;
  }

  // This is a manual deletion - delete all assignments for fairness
  console.log(`Task ${taskId} was manually deleted - deleting all assignments`);

  const assignmentsSnapshot = await db
    .collection("assignments")
    .where("taskId", "==", taskId)
    .get();

  if (assignmentsSnapshot.empty) {
    console.log(`No assignments found for task ${taskId}`);
    return;
  }

  // Batch delete assignments (max 500 per batch)
  const assignmentDocs = assignmentsSnapshot.docs;
  let deletedCount = 0;

  for (let i = 0; i < assignmentDocs.length; i += 500) {
    const batch = db.batch();
    const chunk = assignmentDocs.slice(i, i + 500);
    chunk.forEach((assignmentDoc) => {
      batch.delete(assignmentDoc.ref);
    });
    await batch.commit();
    deletedCount += chunk.length;
  }

  console.log(`Deleted ${deletedCount} assignments for manually deleted task ${taskId}`);
});

/**
 * Scheduled: Delete non-recurring tasks after midnight
 * Runs daily at 00:05 AM (Riyadh time) to permanently delete all non-recurring, non-archived tasks
 * that were created before today.
 * NOTE: Assignments are NOT deleted - they are preserved for user statistics/history.
 * A marker is set before deletion to distinguish from manual deletions.
 */
export const deleteNonRecurringTasks = onSchedule({
  schedule: "5 0 * * *", // Run at 00:05 AM every day
  timeZone: "Asia/Riyadh",
}, async () => {
  console.log("Starting non-recurring tasks deletion...");

  // Calculate midnight Riyadh time in UTC
  // Riyadh is UTC+3, so midnight Riyadh = 21:00 UTC previous day
  const now = new Date();
  const riyadhOffsetMs = 3 * 60 * 60 * 1000; // 3 hours in milliseconds

  // Get current time shifted to represent Riyadh time
  const riyadhNow = new Date(now.getTime() + riyadhOffsetMs);

  // Extract Riyadh date components using UTC methods (since riyadhNow is already shifted)
  const year = riyadhNow.getUTCFullYear();
  const month = riyadhNow.getUTCMonth();
  const date = riyadhNow.getUTCDate();

  // Create midnight UTC for Riyadh date, then subtract offset to get midnight Riyadh in UTC
  const todayStart = new Date(Date.UTC(year, month, date, 0, 0, 0, 0) - riyadhOffsetMs);

  console.log(`Today start (midnight Riyadh in UTC): ${todayStart.toISOString()}`);

  // Get all non-recurring, non-archived tasks
  // Archived tasks should be preserved (user explicitly archived them)
  const tasksSnapshot = await db
    .collection("tasks")
    .where("isRecurring", "==", false)
    .where("isArchived", "==", false)
    .get();

  if (tasksSnapshot.empty) {
    console.log("No non-recurring tasks found");
    return;
  }

  let deletedTasksCount = 0;

  for (const doc of tasksSnapshot.docs) {
    const task = doc.data() as Task;
    const taskCreatedAt = task.createdAt.toDate();

    // Delete if the task was created before today
    if (taskCreatedAt < todayStart) {
      const taskId = doc.id;

      // Set a marker to indicate this is a scheduled deletion (preserves assignments)
      await db.collection("_scheduledDeletions").doc(taskId).set({
        deletedAt: Timestamp.now(),
      });

      // Delete the task - the onTaskDeleted trigger will check for the marker
      await doc.ref.delete();
      deletedTasksCount++;
      console.log(`Deleted task: ${taskId} - ${task.title}`);
    }
  }

  console.log(`Deletion complete: ${deletedTasksCount} non-recurring tasks deleted (assignments preserved for statistics)`);
});

/**
 * HTTP Trigger: Manually delete old non-recurring tasks
 * Can be called by admins to immediately clean up old tasks
 */
export const manualDeleteOldTasks = onCall(async (request) => {
  // Check if user is authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }

  // Get user role
  const userDoc = await db.collection("users").doc(request.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can trigger this function");
  }

  console.log("Manual trigger: Starting non-recurring tasks deletion...");

  // Calculate midnight Riyadh time in UTC
  const now = new Date();
  const riyadhOffsetMs = 3 * 60 * 60 * 1000;
  const riyadhNow = new Date(now.getTime() + riyadhOffsetMs);
  const year = riyadhNow.getUTCFullYear();
  const month = riyadhNow.getUTCMonth();
  const date = riyadhNow.getUTCDate();
  const todayStart = new Date(Date.UTC(year, month, date, 0, 0, 0, 0) - riyadhOffsetMs);

  console.log(`Today start (midnight Riyadh in UTC): ${todayStart.toISOString()}`);

  // Get all non-recurring, non-archived tasks
  const tasksSnapshot = await db
    .collection("tasks")
    .where("isRecurring", "==", false)
    .where("isArchived", "==", false)
    .get();

  if (tasksSnapshot.empty) {
    return { success: true, message: "No non-recurring tasks found", deletedCount: 0 };
  }

  let deletedTasksCount = 0;
  const deletedTasks: { id: string; title: string }[] = [];

  for (const doc of tasksSnapshot.docs) {
    const task = doc.data() as Task;
    const taskCreatedAt = task.createdAt.toDate();

    if (taskCreatedAt < todayStart) {
      const taskId = doc.id;

      // Set marker for scheduled deletion
      await db.collection("_scheduledDeletions").doc(taskId).set({
        deletedAt: Timestamp.now(),
      });

      await doc.ref.delete();
      deletedTasksCount++;
      deletedTasks.push({ id: taskId, title: task.title });
      console.log(`Deleted task: ${taskId} - ${task.title}`);
    }
  }

  return {
    success: true,
    message: `Deleted ${deletedTasksCount} old non-recurring tasks`,
    deletedCount: deletedTasksCount,
    deletedTasks,
  };
});

/**
 * HTTP Endpoint: Trigger cleanup of old non-recurring tasks
 * Can be called via: curl https://REGION-PROJECT.cloudfunctions.net/triggerTaskCleanup
 * WARNING: Remove or secure this endpoint in production!
 */
export const triggerTaskCleanup = onRequest(async (req, res) => {
  console.log("HTTP trigger: Starting non-recurring tasks deletion...");

  // Calculate midnight Riyadh time in UTC
  const now = new Date();
  const riyadhOffsetMs = 3 * 60 * 60 * 1000;
  const riyadhNow = new Date(now.getTime() + riyadhOffsetMs);
  const year = riyadhNow.getUTCFullYear();
  const month = riyadhNow.getUTCMonth();
  const date = riyadhNow.getUTCDate();
  const todayStart = new Date(Date.UTC(year, month, date, 0, 0, 0, 0) - riyadhOffsetMs);

  console.log(`Today start (midnight Riyadh in UTC): ${todayStart.toISOString()}`);

  // Get all non-recurring, non-archived tasks
  const tasksSnapshot = await db
    .collection("tasks")
    .where("isRecurring", "==", false)
    .where("isArchived", "==", false)
    .get();

  if (tasksSnapshot.empty) {
    res.json({ success: true, message: "No non-recurring tasks found", deletedCount: 0 });
    return;
  }

  let deletedTasksCount = 0;
  const deletedTasks: { id: string; title: string }[] = [];

  for (const doc of tasksSnapshot.docs) {
    const task = doc.data() as Task;
    const taskCreatedAt = task.createdAt.toDate();

    if (taskCreatedAt < todayStart) {
      const taskId = doc.id;

      // Set marker for scheduled deletion
      await db.collection("_scheduledDeletions").doc(taskId).set({
        deletedAt: Timestamp.now(),
      });

      await doc.ref.delete();
      deletedTasksCount++;
      deletedTasks.push({ id: taskId, title: task.title });
      console.log(`Deleted task: ${taskId} - ${task.title}`);
    }
  }

  res.json({
    success: true,
    message: `Deleted ${deletedTasksCount} old non-recurring tasks`,
    deletedCount: deletedTasksCount,
    deletedTasks,
  });
});

// ============================================
// OVERDUE ASSIGNMENTS & DEADLINE WARNINGS
// ============================================

/**
 * Scheduled: Mark pending assignments as overdue
 * Runs at 20:10 (10 minutes after default deadline)
 * This marks all pending assignments for today as 'overdue'
 */
export const markOverdueAssignments = onSchedule({
  schedule: "10 20 * * *", // Run at 20:10 every day (10 min after 20:00 deadline)
  timeZone: "Asia/Riyadh",
}, async () => {
  console.log("Starting overdue assignments marking...");

  // Get settings for deadline time
  const settings = await getSettings();
  console.log(`Current deadline setting: ${settings.taskDeadline}`);

  // Calculate today's date range in Riyadh timezone
  const now = new Date();
  const riyadhOffsetMs = 3 * 60 * 60 * 1000;
  const riyadhNow = new Date(now.getTime() + riyadhOffsetMs);

  // Today's start and end in UTC (adjusted for Riyadh)
  const year = riyadhNow.getUTCFullYear();
  const month = riyadhNow.getUTCMonth();
  const date = riyadhNow.getUTCDate();
  const todayStart = new Date(Date.UTC(year, month, date, 0, 0, 0, 0) - riyadhOffsetMs);
  const todayEnd = new Date(todayStart.getTime() + 24 * 60 * 60 * 1000);

  console.log(`Today range: ${todayStart.toISOString()} to ${todayEnd.toISOString()}`);

  // Find all pending assignments scheduled for today
  const pendingSnapshot = await db
    .collection("assignments")
    .where("status", "==", "pending")
    .where("scheduledDate", ">=", Timestamp.fromDate(todayStart))
    .where("scheduledDate", "<", Timestamp.fromDate(todayEnd))
    .get();

  if (pendingSnapshot.empty) {
    console.log("No pending assignments found for today");
    return;
  }

  console.log(`Found ${pendingSnapshot.size} pending assignments to mark as overdue`);

  // Batch update assignments to 'overdue' status
  const overdueTimestamp = Timestamp.now();
  let updatedCount = 0;
  const userOverdueCounts: Map<string, number> = new Map();

  for (let i = 0; i < pendingSnapshot.docs.length; i += 500) {
    const batch = db.batch();
    const chunk = pendingSnapshot.docs.slice(i, i + 500);

    chunk.forEach((doc) => {
      const data = doc.data();
      const userId = data.userId;

      batch.update(doc.ref, {
        status: "overdue",
        overdueAt: overdueTimestamp,
      });
      updatedCount++;

      // Track overdue count per user for notifications
      userOverdueCounts.set(userId, (userOverdueCounts.get(userId) || 0) + 1);
    });

    await batch.commit();
  }

  console.log(`Marked ${updatedCount} assignments as overdue`);

  // Create notifications for users with overdue assignments
  const notificationBatch = db.batch();
  let notificationCount = 0;

  for (const [userId, count] of userOverdueCounts) {
    const notificationRef = db.collection("notifications").doc();
    notificationBatch.set(notificationRef, {
      userId,
      type: "taskOverdue",
      title: "مهام متأخرة",
      body: count === 1
        ? "لديك مهمة واحدة متأخرة لم يتم إنجازها قبل الموعد النهائي"
        : `لديك ${count} مهام متأخرة لم يتم إنجازها قبل الموعد النهائي`,
      iconName: "error",
      iconColor: "#EF4444",
      deepLink: "/", // Link to home/today's tasks
      isSeen: false,
      isRead: false,
      createdAt: overdueTimestamp,
    });
    notificationCount++;
  }

  if (notificationCount > 0) {
    await notificationBatch.commit();
    console.log(`Created ${notificationCount} overdue notifications`);
  }

  console.log("Overdue marking complete");
});

/**
 * Scheduled: Send deadline warning notifications
 * Runs at 19:00 (1 hour before default deadline)
 * Warns users who have pending assignments
 */
export const sendDeadlineWarnings = onSchedule({
  schedule: "0 19 * * *", // Run at 19:00 every day
  timeZone: "Asia/Riyadh",
}, async () => {
  console.log("Starting deadline warning notifications...");

  // Get settings
  const settings = await getSettings();
  console.log(`Deadline setting: ${settings.taskDeadline}`);

  // Calculate today's date range in Riyadh timezone
  const now = new Date();
  const riyadhOffsetMs = 3 * 60 * 60 * 1000;
  const riyadhNow = new Date(now.getTime() + riyadhOffsetMs);

  const year = riyadhNow.getUTCFullYear();
  const month = riyadhNow.getUTCMonth();
  const date = riyadhNow.getUTCDate();
  const todayStart = new Date(Date.UTC(year, month, date, 0, 0, 0, 0) - riyadhOffsetMs);
  const todayEnd = new Date(todayStart.getTime() + 24 * 60 * 60 * 1000);

  // Find all pending assignments scheduled for today
  const pendingSnapshot = await db
    .collection("assignments")
    .where("status", "==", "pending")
    .where("scheduledDate", ">=", Timestamp.fromDate(todayStart))
    .where("scheduledDate", "<", Timestamp.fromDate(todayEnd))
    .get();

  if (pendingSnapshot.empty) {
    console.log("No pending assignments found - no warnings needed");
    return;
  }

  // Group by user
  const userPendingCounts: Map<string, number> = new Map();
  pendingSnapshot.docs.forEach((doc) => {
    const userId = doc.data().userId;
    userPendingCounts.set(userId, (userPendingCounts.get(userId) || 0) + 1);
  });

  console.log(`Found ${userPendingCounts.size} users with pending assignments`);

  // Create warning notifications
  const warningTimestamp = Timestamp.now();
  const batch = db.batch();
  let notificationCount = 0;

  for (const [userId, count] of userPendingCounts) {
    const notificationRef = db.collection("notifications").doc();
    batch.set(notificationRef, {
      userId,
      type: "deadlineWarning",
      title: "تذكير بالموعد النهائي",
      body: count === 1
        ? `لديك مهمة واحدة لم تنجزها بعد. الموعد النهائي ${settings.taskDeadline}`
        : `لديك ${count} مهام لم تنجزها بعد. الموعد النهائي ${settings.taskDeadline}`,
      iconName: "schedule",
      iconColor: "#F59E0B",
      deepLink: "/", // Link to home/today's tasks
      isSeen: false,
      isRead: false,
      createdAt: warningTimestamp,
    });
    notificationCount++;
  }

  await batch.commit();
  console.log(`Sent ${notificationCount} deadline warning notifications`);
});

// ============================================
// ASSIGNMENT STATUS CHANGE NOTIFICATIONS
// ============================================

/**
 * Trigger: When an assignment is updated
 * Creates notifications for status changes (completed, apologized, marked done)
 */
export const onAssignmentUpdated = onDocumentUpdated("assignments/{assignmentId}", async (event) => {
  const change = event.data;
  if (!change) {
    console.log("No data associated with the event");
    return;
  }

  const assignmentId = event.params.assignmentId;
  const before = change.before.data() as Assignment;
  const after = change.after.data() as Assignment;

  // Skip if status didn't change
  if (before.status === after.status) {
    return;
  }

  const timestamp = Timestamp.now();

  // Assignment completed
  if (after.status === "completed" && before.status !== "completed") {
    console.log(`Assignment ${assignmentId} completed by user ${after.userId}`);

    // Get task and user details
    const taskDoc = await db.collection("tasks").doc(after.taskId).get();
    if (!taskDoc.exists) return;

    const task = taskDoc.data() as Task;
    const userDoc = await db.collection("users").doc(after.userId).get();
    const userName = userDoc.exists
      ? `${userDoc.data()?.firstName || ""} ${userDoc.data()?.lastName || ""}`.trim()
      : "مستخدم";

    // Notify task creator (use task ID for deepLink since creator needs to see task, not assignment)
    const notificationRef = db.collection("notifications").doc();
    await notificationRef.set({
      userId: task.createdBy,
      type: "taskCompleted",
      title: "مهمة منجزة",
      body: `أنجز ${userName} المهمة: ${task.title}`,
      iconName: "check_circle",
      iconColor: "#10B981",
      deepLink: `/tasks/${after.taskId}`,
      isSeen: false,
      isRead: false,
      createdAt: timestamp,
    });
    console.log(`Created completion notification for task creator ${task.createdBy}`);
  }

  // Assignment apologized
  if (after.status === "apologized" && before.status !== "apologized") {
    console.log(`Assignment ${assignmentId} apologized by user ${after.userId}`);

    // Get task and user details
    const taskDoc = await db.collection("tasks").doc(after.taskId).get();
    if (!taskDoc.exists) return;

    const task = taskDoc.data() as Task;
    const userDoc = await db.collection("users").doc(after.userId).get();
    const userName = userDoc.exists
      ? `${userDoc.data()?.firstName || ""} ${userDoc.data()?.lastName || ""}`.trim()
      : "مستخدم";

    const apologizeMessage = after.apologizeMessage || "بدون سبب";

    // Notify task creator (use task ID for deepLink since creator needs to see task, not assignment)
    const notificationRef = db.collection("notifications").doc();
    await notificationRef.set({
      userId: task.createdBy,
      type: "taskApologized",
      title: "اعتذار عن مهمة",
      body: `اعتذر ${userName} عن المهمة: ${task.title} - السبب: ${apologizeMessage}`,
      iconName: "warning",
      iconColor: "#F59E0B",
      deepLink: `/tasks/${after.taskId}`,
      isSeen: false,
      isRead: false,
      createdAt: timestamp,
    });
    console.log(`Created apologize notification for task creator ${task.createdBy}`);
  }
});

// ============================================
// CLOUDINARY SIGNED UPLOADS
// ============================================

// Cloudinary configuration
const CLOUDINARY_CLOUD_NAME = "dj16a87b9";
const CLOUDINARY_API_KEY = "777665224244565";

/**
 * Generate Cloudinary signature for signed uploads
 * This enables overwrite and other restricted features
 */
export const getCloudinarySignature = onCall({
  secrets: [cloudinaryApiSecret],
}, async (request) => {
  // Check if user is authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }

  const { folder, publicId, overwrite, uploadType } = request.data;

  if (!folder || !publicId) {
    throw new HttpsError("invalid-argument", "folder and publicId are required");
  }

  // Validate upload type
  const validTypes = ["avatar", "attachment"];
  if (uploadType && !validTypes.includes(uploadType)) {
    throw new HttpsError("invalid-argument", "Invalid upload type");
  }

  // Generate timestamp
  const timestamp = Math.round(Date.now() / 1000);

  // Build params to sign (must be alphabetically sorted)
  const paramsToSign: Record<string, string | number | boolean> = {
    folder,
    overwrite: overwrite === true,
    public_id: publicId,
    timestamp,
  };

  // Create signature string (params sorted alphabetically)
  const sortedParams = Object.keys(paramsToSign)
    .sort()
    .map((key) => `${key}=${paramsToSign[key]}`)
    .join("&");

  // Generate SHA-1 signature
  const apiSecret = cloudinaryApiSecret.value();
  const signature = crypto
    .createHash("sha1")
    .update(sortedParams + apiSecret)
    .digest("hex");

  console.log(`Generated Cloudinary signature for user ${request.auth.uid}: ${folder}/${publicId}`);

  return {
    signature,
    timestamp,
    apiKey: CLOUDINARY_API_KEY,
    cloudName: CLOUDINARY_CLOUD_NAME,
    folder,
    publicId,
    overwrite: overwrite === true,
  };
});

/**
 * Delete a file from Cloudinary (for cleanup)
 * Used when replacing avatars or removing attachments
 */
export const deleteCloudinaryFile = onCall({
  secrets: [cloudinaryApiSecret],
}, async (request) => {
  // Check if user is authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }

  const { publicId, resourceType = "image" } = request.data;

  if (!publicId) {
    throw new HttpsError("invalid-argument", "publicId is required");
  }

  // Generate timestamp
  const timestamp = Math.round(Date.now() / 1000);

  // Build params to sign
  const paramsToSign = `public_id=${publicId}&timestamp=${timestamp}`;

  // Generate signature
  const apiSecret = cloudinaryApiSecret.value();
  const signature = crypto
    .createHash("sha1")
    .update(paramsToSign + apiSecret)
    .digest("hex");

  // Call Cloudinary destroy API
  const formData = new URLSearchParams({
    public_id: publicId,
    signature,
    api_key: CLOUDINARY_API_KEY,
    timestamp: timestamp.toString(),
  });

  try {
    const response = await fetch(
      `https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}/${resourceType}/destroy`,
      {
        method: "POST",
        body: formData,
      }
    );

    const result = await response.json();
    console.log(`Deleted Cloudinary file: ${publicId}, result: ${JSON.stringify(result)}`);

    return {
      success: result.result === "ok",
      result: result.result,
    };
  } catch (error) {
    console.error(`Error deleting Cloudinary file: ${publicId}`, error);
    throw new HttpsError("internal", "Failed to delete file from Cloudinary");
  }
});

/**
 * Verify a user's email manually (admin-only function)
 * Usage: Call this function with the email address to verify
 */
export const verifyUserEmail = onCall(async (request) => {
  const { email } = request.data;

  if (!email) {
    throw new HttpsError("invalid-argument", "Email is required");
  }

  try {
    // Get user by email
    const user = await getAuth().getUserByEmail(email);

    // Update user to set emailVerified to true
    await getAuth().updateUser(user.uid, {
      emailVerified: true,
    });

    console.log(`✅ Email verified for ${email} (UID: ${user.uid})`);

    return {
      success: true,
      message: `Email verified for ${email}`,
      uid: user.uid,
    };
  } catch (error: any) {
    console.error(`Error verifying email for ${email}:`, error);
    throw new HttpsError("internal", `Failed to verify email: ${error.message}`);
  }
});
