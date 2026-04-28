import 'package:firebase_database/firebase_database.dart';
import '../models/crisis.dart';

class CrisisService {
  final _db = FirebaseDatabase.instance.ref();

  Future<String> triggerSOS({
    required String type,
    required String room,
  }) async {
    final floor = room.isNotEmpty ? int.tryParse(room[0]) ?? 0 : 0;
    final ref = _db.child('crises').push();
    await ref.set({
      'type': type,
      'room': room,
      'floor': floor,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': 'active',
    });
    return ref.key ?? '';
  }

  Stream<List<Crisis>> getActiveCrises() {
    return _db
        .child('crises')
        .orderByChild('status')
        .equalTo('active')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <Crisis>[];
      final map = Map<dynamic, dynamic>.from(data as Map);
      final list = map.entries
          .map((e) => Crisis.fromMap(
                e.key as String,
                Map<dynamic, dynamic>.from(e.value as Map),
              ))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> resolveCrisis(String crisisId) async {
    await _db.child('crises/$crisisId').update({
      'status': 'resolved',
      'resolvedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
