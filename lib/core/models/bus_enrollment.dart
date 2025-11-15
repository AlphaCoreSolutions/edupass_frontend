enum BusJoinStatus {
  pending,
  approvedAwaitingPayment,
  paid,
  rejected,
  cancelled,
}

class BusEnrollmentApi {
  final int id; // internal id
  final int studentId;
  final int busId;
  final int requestedById; // parent user id
  final DateTime requestedAt;
  final BusJoinStatus status;
  final String? paymentRef; // set when paid

  const BusEnrollmentApi({
    required this.id,
    required this.studentId,
    required this.busId,
    required this.requestedById,
    required this.requestedAt,
    required this.status,
    this.paymentRef,
  });

  BusEnrollmentApi copyWith({BusJoinStatus? status, String? paymentRef}) =>
      BusEnrollmentApi(
        id: id,
        studentId: studentId,
        busId: busId,
        requestedById: requestedById,
        requestedAt: requestedAt,
        status: status ?? this.status,
        paymentRef: paymentRef ?? this.paymentRef,
      );

  factory BusEnrollmentApi.fromJson(Map<String, dynamic> json) =>
      BusEnrollmentApi(
        id: json['id'] as int,
        studentId: json['studentId'] as int,
        busId: json['busId'] as int,
        requestedById: json['requestedById'] as int,
        requestedAt: DateTime.parse(json['requestedAt'] as String),
        status: BusJoinStatus.values.firstWhere(
          (e) => e.toString() == json['status'] as String,
          orElse: () => BusJoinStatus.pending,
        ),
        paymentRef: json['paymentRef'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'busId': busId,
    'requestedById': requestedById,
    'requestedAt': requestedAt.toIso8601String(),
    'status': status.toString(),
    'paymentRef': paymentRef,
  };
}
