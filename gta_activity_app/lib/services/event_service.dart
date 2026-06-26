import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';

class EventService {
  final CollectionReference<Map<String, dynamic>> _eventsRef =
      FirebaseFirestore.instance.collection('events');

  /// Streams all active events, ordered by start date.
  Stream<List<Event>> watchActiveEvents() {
    return _eventsRef
        .where('active', isEqualTo: true)
        .orderBy('start_date')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }
}
