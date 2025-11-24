import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/settings_model.dart';
import '../services/firestore_service.dart';

/// Settings repository for app configuration
@lazySingleton
class SettingsRepository {
  final FirestoreService _firestoreService;

  SettingsRepository(this._firestoreService);

  /// Get global settings
  Future<SettingsModel> getSettings() async {
    final doc = await _firestoreService.globalSettingsDoc.get();
    if (!doc.exists) {
      // Return defaults without writing - user may not have write permission
      return SettingsModel.defaults();
    }
    return SettingsModel.fromFirestore(doc);
  }

  /// Stream global settings
  Stream<SettingsModel> streamSettings() {
    return _firestoreService
        .streamDocument(_firestoreService.globalSettingsDoc)
        .map((doc) {
      if (!doc.exists) return SettingsModel.defaults();
      return SettingsModel.fromFirestore(doc);
    });
  }

  /// Update recurring task time
  Future<void> updateRecurringTaskTime(String time) async {
    await _firestoreService.setDocument(
      _firestoreService.globalSettingsDoc,
      {FirebaseConstants.settingsRecurringTaskTime: time},
      merge: true,
    );
  }

  /// Update task deadline
  Future<void> updateTaskDeadline(String time) async {
    await _firestoreService.setDocument(
      _firestoreService.globalSettingsDoc,
      {FirebaseConstants.settingsTaskDeadline: time},
      merge: true,
    );
  }

  /// Update all settings
  Future<void> updateSettings(SettingsModel settings) async {
    await _firestoreService.setDocument(
      _firestoreService.globalSettingsDoc,
      settings.toFirestore(),
      merge: true,
    );
  }
}
