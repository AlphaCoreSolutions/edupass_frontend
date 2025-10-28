class StudentApi {
  final int id;
  final String name;
  final String grade;
  final String idNumber;
  final int genderId; // ↔ LookupDomainDetail(Gender)
  final String? imagePath;

  StudentApi({
    required this.id,
    required this.name,
    required this.grade,
    required this.idNumber,
    required this.genderId,
    this.imagePath,
  });

  factory StudentApi.fromJson(Map<String, dynamic> json) => StudentApi(
    id: json['id'],
    name: json['name'],
    grade: json['grade'],
    idNumber: json['idNumber'],
    genderId: json['genderId'],
    imagePath: json['imagePath'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'grade': grade,
    'idNumber': idNumber,
    'genderId': genderId,
    'imagePath': imagePath,
  };
}
