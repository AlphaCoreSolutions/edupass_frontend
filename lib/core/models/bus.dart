class BusApi {
  final int id;
  final String name; // e.g., "Bus 5 – حي الياسمين"
  final String neighborhood; // الحي
  final String routeDescription; // free text for now
  final List<String> weekdays; // ["Sun","Mon",...]
  final String pickupTime; // HH:mm school → home
  final String dropoffTime; // HH:mm home → school (optional)
  final double monthlyFee; // general fee
  final int supervisorUserId; // who manages approvals

  const BusApi({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.routeDescription,
    required this.weekdays,
    required this.pickupTime,
    required this.dropoffTime,
    required this.monthlyFee,
    required this.supervisorUserId,
  });

  BusApi copyWith({
    int? id,
    String? name,
    String? neighborhood,
    String? routeDescription,
    List<String>? weekdays,
    String? pickupTime,
    String? dropoffTime,
    double? monthlyFee,
    int? supervisorUserId,
  }) => BusApi(
    id: id ?? this.id,
    name: name ?? this.name,
    neighborhood: neighborhood ?? this.neighborhood,
    routeDescription: routeDescription ?? this.routeDescription,
    weekdays: weekdays ?? this.weekdays,
    pickupTime: pickupTime ?? this.pickupTime,
    dropoffTime: dropoffTime ?? this.dropoffTime,
    monthlyFee: monthlyFee ?? this.monthlyFee,
    supervisorUserId: supervisorUserId ?? this.supervisorUserId,
  );

  factory BusApi.fromJson(Map<String, dynamic> json) => BusApi(
    id: json['id'] as int,
    name: json['name'] as String,
    neighborhood: json['neighborhood'] as String,
    routeDescription: json['routeDescription'] as String,
    weekdays: (json['weekdays'] as List).map((e) => e as String).toList(),
    pickupTime: json['pickupTime'] as String,
    dropoffTime: json['dropoffTime'] as String,
    monthlyFee: (json['monthlyFee'] as num).toDouble(),
    supervisorUserId: json['supervisorUserId'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'neighborhood': neighborhood,
    'routeDescription': routeDescription,
    'weekdays': weekdays,
    'pickupTime': pickupTime,
    'dropoffTime': dropoffTime,
    'monthlyFee': monthlyFee,
    'supervisorUserId': supervisorUserId,
  };
}
