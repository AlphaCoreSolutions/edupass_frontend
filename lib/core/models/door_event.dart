class DoorEventApi {
  final int id;
  final int studentId;
  final int pickedByType; // 0 = Parent, 1 = AuthorizedPerson, 2 = Bus
  final int? pickedById; // userId or authorizedPersonId or busId
  final DateTime time;
  final String? note;

  const DoorEventApi({
    required this.id,
    required this.studentId,
    required this.pickedByType,
    this.pickedById,
    required this.time,
    this.note,
  });

  DoorEventApi copyWith({
    int? id,
    int? studentId,
    int? pickedByType,
    int? pickedById,
    DateTime? time,
    String? note,
  }) => DoorEventApi(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    pickedByType: pickedByType ?? this.pickedByType,
    pickedById: pickedById ?? this.pickedById,
    time: time ?? this.time,
    note: note ?? this.note,
  );

  factory DoorEventApi.fromJson(Map<String, dynamic> json) => DoorEventApi(
    id: json['id'] as int,
    studentId: json['studentId'] as int,
    pickedByType: json['pickedByType'] as int,
    pickedById: json['pickedById'] as int?,
    time: DateTime.parse(json['time'] as String),
    note: json['note'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'pickedByType': pickedByType,
    'pickedById': pickedById,
    'time': time.toIso8601String(),
    'note': note,
  };
}
