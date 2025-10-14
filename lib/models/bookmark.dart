import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Bookmark {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String contentType;
  @HiveField(2)
  final int objectId;
  @HiveField(3)
  final String notes;
  @HiveField(4)
  final String? contentTitle;
  @HiveField(5)
  final Map<String, dynamic>? contentDetails;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime updatedAt;

  Bookmark({
    required this.id,
    required this.contentType,
    required this.objectId,
    required this.notes,
    this.contentTitle,
    this.contentDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      contentType: json['content_type'],
      objectId: json['object_id'],
      notes: json['notes'] ?? '',
      contentTitle: json['content_title'],
      contentDetails: json['content_details'] != null
          ? Map<String, dynamic>.from(json['content_details'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_type': contentType,
      'object_id': objectId,
      'notes': notes,
      'content_title': contentTitle,
      'content_details': contentDetails,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
