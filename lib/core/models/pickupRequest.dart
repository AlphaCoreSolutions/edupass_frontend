class PickupRequestApi {
  final int id;
  final int studentId;
  final int requestTypeId; // ↔ LookupDomainDetail(RequestType)
  final int requestedById; // ↔ User
  final DateTime time;
  final int statusId; // ↔ LookupDomainDetail(RequestStatus)
  final DateTime? exitTime;
  final int? reasonId; // ↔ LookupDomainDetail(PickupReason)
  final String? attachmentUrl;

  PickupRequestApi({
    required this.id,
    required this.studentId,
    required this.requestTypeId,
    required this.requestedById,
    required this.time,
    required this.statusId,
    this.exitTime,
    this.reasonId,
    this.attachmentUrl,
  });

  factory PickupRequestApi.fromJson(Map<String, dynamic> json) =>
      PickupRequestApi(
        id: json['id'],
        studentId: json['studentId'],
        requestTypeId: json['requestTypeId'],
        requestedById: json['requestedById'],
        time: DateTime.parse(json['time']),
        statusId: json['statusId'],
        exitTime: json['exitTime'] != null
            ? DateTime.parse(json['exitTime'])
            : null,
        reasonId: json['reasonId'],
        attachmentUrl: json['attachmentUrl'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'requestTypeId': requestTypeId,
    'requestedById': requestedById,
    'time': time.toIso8601String(),
    'statusId': statusId,
    'exitTime': exitTime?.toIso8601String(),
    'reasonId': reasonId,
    'attachmentUrl': attachmentUrl,
  };

  PickupRequestApi copyWith({
    int? id,
    int? studentId,
    int? requestTypeId,
    int? requestedById,
    DateTime? time,
    int? statusId,
    DateTime? exitTime,
    int? reasonId,
    String? attachmentUrl,
  }) {
    return PickupRequestApi(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      requestTypeId: requestTypeId ?? this.requestTypeId,
      requestedById: requestedById ?? this.requestedById,
      time: time ?? this.time,
      statusId: statusId ?? this.statusId,
      exitTime: exitTime ?? this.exitTime,
      reasonId: reasonId ?? this.reasonId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
