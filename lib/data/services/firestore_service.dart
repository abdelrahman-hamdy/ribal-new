import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';

/// Firestore database service
@lazySingleton
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // COLLECTION REFERENCES
  // ============================================

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> get tasksCollection =>
      _firestore.collection(FirebaseConstants.tasksCollection);

  CollectionReference<Map<String, dynamic>> get assignmentsCollection =>
      _firestore.collection(FirebaseConstants.assignmentsCollection);

  CollectionReference<Map<String, dynamic>> get groupsCollection =>
      _firestore.collection(FirebaseConstants.groupsCollection);

  CollectionReference<Map<String, dynamic>> get labelsCollection =>
      _firestore.collection(FirebaseConstants.labelsCollection);

  CollectionReference<Map<String, dynamic>> get whitelistCollection =>
      _firestore.collection(FirebaseConstants.whitelistCollection);

  CollectionReference<Map<String, dynamic>> get invitationsCollection =>
      _firestore.collection(FirebaseConstants.invitationsCollection);

  CollectionReference<Map<String, dynamic>> get notificationsCollection =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  CollectionReference<Map<String, dynamic>> get settingsCollection =>
      _firestore.collection(FirebaseConstants.settingsCollection);

  // ============================================
  // DOCUMENT REFERENCES
  // ============================================

  DocumentReference<Map<String, dynamic>> get globalSettingsDoc =>
      settingsCollection.doc(FirebaseConstants.globalSettingsDoc);

  DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      usersCollection.doc(userId);

  DocumentReference<Map<String, dynamic>> taskDoc(String taskId) =>
      tasksCollection.doc(taskId);

  DocumentReference<Map<String, dynamic>> assignmentDoc(String assignmentId) =>
      assignmentsCollection.doc(assignmentId);

  DocumentReference<Map<String, dynamic>> groupDoc(String groupId) =>
      groupsCollection.doc(groupId);

  DocumentReference<Map<String, dynamic>> labelDoc(String labelId) =>
      labelsCollection.doc(labelId);

  DocumentReference<Map<String, dynamic>> whitelistDoc(String id) =>
      whitelistCollection.doc(id);

  DocumentReference<Map<String, dynamic>> invitationDoc(String code) =>
      invitationsCollection.doc(code);

  DocumentReference<Map<String, dynamic>> notificationDoc(String id) =>
      notificationsCollection.doc(id);

  // ============================================
  // BATCH & TRANSACTION HELPERS
  // ============================================

  WriteBatch get batch => _firestore.batch();

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) {
    return _firestore.runTransaction(transactionHandler);
  }

  // ============================================
  // GENERIC CRUD OPERATIONS
  // ============================================

  /// Create document with auto-generated ID
  Future<DocumentReference<Map<String, dynamic>>> createDocument(
    CollectionReference<Map<String, dynamic>> collection,
    Map<String, dynamic> data,
  ) async {
    return await collection.add(data);
  }

  /// Create document with specific ID
  Future<void> setDocument(
    DocumentReference<Map<String, dynamic>> docRef,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await docRef.set(data, SetOptions(merge: merge));
  }

  /// Update document
  Future<void> updateDocument(
    DocumentReference<Map<String, dynamic>> docRef,
    Map<String, dynamic> data,
  ) async {
    await docRef.update(data);
  }

  /// Delete document
  Future<void> deleteDocument(
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    await docRef.delete();
  }

  /// Get document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    return await docRef.get();
  }

  /// Get documents from query
  Future<QuerySnapshot<Map<String, dynamic>>> getDocuments(
    Query<Map<String, dynamic>> query,
  ) async {
    return await query.get();
  }

  /// Stream single document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    DocumentReference<Map<String, dynamic>> docRef,
  ) {
    return docRef.snapshots();
  }

  /// Stream query results
  Stream<QuerySnapshot<Map<String, dynamic>>> streamQuery(
    Query<Map<String, dynamic>> query,
  ) {
    return query.snapshots();
  }

  // ============================================
  // TIMESTAMP HELPERS
  // ============================================

  Timestamp get serverTimestamp => Timestamp.now();

  FieldValue get serverTimestampField => FieldValue.serverTimestamp();

  Timestamp dateToTimestamp(DateTime date) => Timestamp.fromDate(date);

  DateTime timestampToDate(Timestamp timestamp) => timestamp.toDate();
}
