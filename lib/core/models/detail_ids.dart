// lib/core/models/detail_ids.dart (optional fast-path)
class DetailIds {
  // Request Type
  static const int normalDismissal = 6;
  static const int earlyLeave = 7;

  // Request Status
  static const int pending = 8;
  static const int approved = 9;
  static const int rejected = 10;
  static const int completed = 11;

  // Gender
  static const int male = 1;
  static const int female = 2;

  // Pickup Reasons
  static const int medical = 12;
  static const int family = 13;
  static const int personal = 16;
  static const int emergency = 17;

  // Roles
  static const int parent = 3;
  static const int supervisor = 4;
  static const int admin = 5;
}
