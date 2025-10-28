class UserApi {
  final int id;
  final String name;
  final int roleId; // ↔ LookupDomainDetail(UserRole)

  UserApi({required this.id, required this.name, required this.roleId});

  factory UserApi.fromJson(Map<String, dynamic> json) =>
      UserApi(id: json['id'], name: json['name'], roleId: json['roleId']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'roleId': roleId};

  UserApi copyWith({String? name, int? roleId}) =>
      UserApi(id: id, name: name ?? this.name, roleId: roleId ?? this.roleId);
}
