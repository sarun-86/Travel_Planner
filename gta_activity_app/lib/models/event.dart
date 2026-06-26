import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String name;
  final String description;
  final String region;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecurring;
  final String recurrenceNote;
  final List<String> audience;
  final String costTier;
  final String costNote;
  final String sourceUrl;
  final String imageUrl;
  final bool active;

  Event({
    required this.eventId,
    required this.name,
    required this.description,
    required this.region,
    required this.startDate,
    required this.endDate,
    required this.isRecurring,
    required this.recurrenceNote,
    required this.audience,
    required this.costTier,
    required this.costNote,
    required this.sourceUrl,
    required this.imageUrl,
    required this.active,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Event(
      eventId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      region: data['region'] ?? '',
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      isRecurring: data['is_recurring'] ?? false,
      recurrenceNote: data['recurrence_note'] ?? '',
      audience: List<String>.from(data['audience'] ?? []),
      costTier: data['cost_tier'] ?? '',
      costNote: data['cost_note'] ?? '',
      sourceUrl: data['source_url'] ?? '',
      imageUrl: data['image_url'] ?? '',
      active: data['active'] ?? true,
    );
  }
}
