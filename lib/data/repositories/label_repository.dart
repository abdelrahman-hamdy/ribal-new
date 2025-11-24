import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/label_model.dart';
import '../services/firestore_service.dart';

/// Label repository for CRUD operations
@lazySingleton
class LabelRepository {
  final FirestoreService _firestoreService;

  LabelRepository(this._firestoreService);

  /// Create label
  Future<LabelModel> createLabel(LabelModel label) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.labelsCollection,
      label.toFirestore(),
    );

    return label.copyWith(id: docRef.id);
  }

  /// Get label by ID
  Future<LabelModel?> getLabelById(String labelId) async {
    final doc = await _firestoreService.labelDoc(labelId).get();
    if (!doc.exists) return null;
    return LabelModel.fromFirestore(doc);
  }

  /// Stream label by ID
  Stream<LabelModel?> streamLabel(String labelId) {
    return _firestoreService
        .streamDocument(_firestoreService.labelDoc(labelId))
        .map((doc) => doc.exists ? LabelModel.fromFirestore(doc) : null);
  }

  /// Get all labels
  Future<List<LabelModel>> getAllLabels() async {
    final snapshot = await _firestoreService.labelsCollection
        .orderBy(FirebaseConstants.labelName)
        .get();

    return snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList();
  }

  /// Stream all labels
  Stream<List<LabelModel>> streamAllLabels() {
    return _firestoreService.labelsCollection
        .orderBy(FirebaseConstants.labelName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList());
  }

  /// Get active labels only
  Future<List<LabelModel>> getActiveLabels() async {
    final snapshot = await _firestoreService.labelsCollection
        .where(FirebaseConstants.labelIsActive, isEqualTo: true)
        .orderBy(FirebaseConstants.labelName)
        .get();

    return snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList();
  }

  /// Stream active labels
  Stream<List<LabelModel>> streamActiveLabels() {
    return _firestoreService.labelsCollection
        .where(FirebaseConstants.labelIsActive, isEqualTo: true)
        .orderBy(FirebaseConstants.labelName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList());
  }

  /// Get labels by IDs
  Future<List<LabelModel>> getLabelsByIds(List<String> labelIds) async {
    if (labelIds.isEmpty) return [];

    final labels = <LabelModel>[];
    for (var i = 0; i < labelIds.length; i += 10) {
      final chunk = labelIds.skip(i).take(10).toList();
      final snapshot = await _firestoreService.labelsCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      labels.addAll(
        snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)),
      );
    }

    return labels;
  }

  /// Update label
  Future<void> updateLabel(LabelModel label) async {
    await _firestoreService.updateDocument(
      _firestoreService.labelDoc(label.id),
      label.toFirestore(),
    );
  }

  /// Toggle label active status
  Future<void> toggleLabelActive(String labelId, bool isActive) async {
    await _firestoreService.updateDocument(
      _firestoreService.labelDoc(labelId),
      {FirebaseConstants.labelIsActive: isActive},
    );
  }

  /// Delete label
  Future<void> deleteLabel(String labelId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.labelDoc(labelId),
    );
  }

  /// Check if label name exists
  Future<bool> labelNameExists(String name, {String? excludeId}) async {
    final snapshot = await _firestoreService.labelsCollection
        .where(FirebaseConstants.labelName, isEqualTo: name)
        .get();

    if (excludeId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeId);
    }
    return snapshot.docs.isNotEmpty;
  }
}
