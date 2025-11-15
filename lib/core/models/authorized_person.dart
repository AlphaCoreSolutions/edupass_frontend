class AuthorizedPickupPersonApi {
  final int id;
  final int parentUserId; // owner parent
  final int studentId; // child this applies to
  final String fullName;
  final String phone;
  final String nationalId;
  final String? relation; // e.g., Uncle / Neighbor
  final String? avatarPath; // optional local path

  const AuthorizedPickupPersonApi({
    required this.id,
    required this.parentUserId,
    required this.studentId,
    required this.fullName,
    required this.phone,
    required this.nationalId,
    this.relation,
    this.avatarPath,
  });

  AuthorizedPickupPersonApi copyWith({
    int? id,
    int? parentUserId,
    int? studentId,
    String? fullName,
    String? phone,
    String? nationalId,
    String? relation,
    String? avatarPath,
  }) => AuthorizedPickupPersonApi(
    id: id ?? this.id,
    parentUserId: parentUserId ?? this.parentUserId,
    studentId: studentId ?? this.studentId,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    nationalId: nationalId ?? this.nationalId,
    relation: relation ?? this.relation,
    avatarPath: avatarPath ?? this.avatarPath,
  );

  factory AuthorizedPickupPersonApi.fromJson(Map<String, dynamic> json) =>
      AuthorizedPickupPersonApi(
        id: json['id'] as int,
        parentUserId: json['parentUserId'] as int,
        studentId: json['studentId'] as int,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        nationalId: json['nationalId'] as String,
        relation: json['relation'] as String?,
        avatarPath: json['avatarPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentUserId': parentUserId,
    'studentId': studentId,
    'fullName': fullName,
    'phone': phone,
    'nationalId': nationalId,
    'relation': relation,
    'avatarPath': avatarPath,
  };
}
