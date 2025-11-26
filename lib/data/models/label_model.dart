import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'label_model.freezed.dart';
part 'label_model.g.dart';

/// Label model for categorizing tasks
@freezed
class LabelModel with _$LabelModel {
  const LabelModel._();

  const factory LabelModel({
    required String id,
    required String name,
    required String color,
    @Default(true) bool isActive,
    required String createdBy,
    required DateTime createdAt,
  }) = _LabelModel;

  factory LabelModel.fromJson(Map<String, dynamic> json) =>
      _$LabelModelFromJson(json);

  /// Create fake data for skeleton loading
  factory LabelModel.fake() => LabelModel(
        id: 'fake-id',
        name: 'تسمية',
        color: '#3B82F6',
        createdBy: 'fake-creator-id',
        createdAt: DateTime.now(),
      );

  /// Create from Firestore document
  factory LabelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LabelModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Predefined label colors enum
enum LabelColor {
  red('#EF4444', 'أحمر'),
  orange('#F97316', 'برتقالي'),
  amber('#F59E0B', 'كهرماني'),
  yellow('#EAB308', 'أصفر'),
  lime('#84CC16', 'ليموني'),
  green('#22C55E', 'أخضر'),
  emerald('#10B981', 'زمردي'),
  teal('#14B8A6', 'أزرق مخضر'),
  cyan('#06B6D4', 'سماوي'),
  sky('#0EA5E9', 'سماوي فاتح'),
  blue('#3B82F6', 'أزرق'),
  indigo('#6366F1', 'نيلي'),
  violet('#8B5CF6', 'بنفسجي'),
  purple('#A855F7', 'أرجواني'),
  fuchsia('#D946EF', 'فوشيا'),
  pink('#EC4899', 'وردي'),
  rose('#F43F5E', 'وردي غامق'),
  stone('#78716C', 'رمادي');

  final String hex;
  final String nameAr;

  const LabelColor(this.hex, this.nameAr);

  /// Get Color object from hex
  Color get color => Color(int.parse(hex.replaceFirst('#', '0xFF')));

  /// Get a lighter version for backgrounds
  Color get surfaceColor => color.withValues(alpha: 0.15);

  /// Find LabelColor by hex string
  static LabelColor fromHex(String hex) {
    return LabelColor.values.firstWhere(
      (c) => c.hex.toLowerCase() == hex.toLowerCase(),
      orElse: () => LabelColor.blue,
    );
  }

  /// Get all hex values as list
  static List<String> get allHex => LabelColor.values.map((c) => c.hex).toList();

  /// Default color
  static const LabelColor defaultColor = LabelColor.blue;
}
