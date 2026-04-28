class Crisis {
  final String id;
  final String type;
  final String room;
  final int floor;
  final int timestamp;
  final String status;
  final String? aiBrief;
  final int? briefAt;
  final int? resolvedAt;

  Crisis({
    required this.id,
    required this.type,
    required this.room,
    required this.floor,
    required this.timestamp,
    required this.status,
    this.aiBrief,
    this.briefAt,
    this.resolvedAt,
  });

  factory Crisis.fromMap(String id, Map<dynamic, dynamic> map) {
    return Crisis(
      id: id,
      type: map['type'] ?? 'other',
      room: map['room'] ?? '000',
      floor: map['floor'] ?? 0,
      timestamp: map['timestamp'] ?? 0,
      status: map['status'] ?? 'active',
      aiBrief: map['aiBrief'],
      briefAt: map['briefAt'],
      resolvedAt: map['resolvedAt'],
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'room': room,
    'floor': floor,
    'timestamp': timestamp,
    'status': status,
  };
}
