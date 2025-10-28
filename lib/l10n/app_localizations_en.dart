// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome 👋';

  @override
  String get settings => 'Settings';

  @override
  String get username => 'Username';

  @override
  String get noStudents => 'No linked students found';

  @override
  String get addStudent => 'Add Student';

  @override
  String get grade => 'Grade';

  @override
  String get idNumber => 'ID Number';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get latestRequest => 'Latest Request';

  @override
  String get cancelNotice => 'You can cancel the request before approval';

  @override
  String get cancel => 'Cancel';

  @override
  String get requestCanceled => 'Request cancelled';

  @override
  String get generatePdf => 'Generate Dismissal Card';

  @override
  String get requestDismissal => 'Request Dismissal';

  @override
  String get requestEarlyLeave => 'Request Early Leave';

  @override
  String get requestHistory => 'Request History:';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get completed => 'Dismissed';

  @override
  String get dismissal => 'Dismissal';

  @override
  String get earlyLeave => 'Early Leave';

  @override
  String get children => 'Children';

  @override
  String get requests => 'Requests';

  @override
  String get account => 'Account';

  @override
  String get myRequests => 'My Requests';

  @override
  String get noRequestsYet => 'No requests yet';

  @override
  String get parentExperimental => 'Parent (Demo)';

  @override
  String get clearRequests => 'Clear All Requests';

  @override
  String get requestsCleared => 'Requests cleared';

  @override
  String get logout => 'Logout';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get studentName => 'Student';

  @override
  String get requestType => 'Request Type';

  @override
  String get requestStatus => 'Status';

  @override
  String get reason => 'Reason';

  @override
  String get typeDismissal => 'Dismissal';

  @override
  String get typeEarlyLeave => 'Early Leave';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get gateTitle => 'School Gate';

  @override
  String get gateNoStudents => 'No students ready to exit';

  @override
  String gateExitSuccess(String name) {
    return '$name has exited through the gate ✅';
  }

  @override
  String get gateExitError => 'An error occurred while updating request status';

  @override
  String get exitDone => 'Mark Exit';

  @override
  String get scanQR => 'Scan Parent QR';

  @override
  String get unknown => 'Unknown';

  @override
  String get qrInvalid => 'Invalid QR code';

  @override
  String get qrNotFound => 'Request not found';

  @override
  String get qrNotApproved => 'Request is not approved';

  @override
  String get qrStudentNotFound => 'Student not found';

  @override
  String get qrConfirmExit => 'Confirm Exit';

  @override
  String qrConfirmExitMessage(String name) {
    return 'Confirm that $name has exited the gate?';
  }

  @override
  String qrExitSuccess(String name) {
    return '$name has exited the gate ✅';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get supervisorTitle => 'Supervisor Dashboard';

  @override
  String get supervisorNoRequests => 'No active requests';

  @override
  String get studentGrade => 'Grade';

  @override
  String get studentId => 'ID Number';

  @override
  String get studentGender => 'Gender';

  @override
  String get requestReason => 'Reason';

  @override
  String get actionApprove => 'Approve';

  @override
  String get actionReject => 'Reject';

  @override
  String get actionComplete => 'Complete';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get smartDisplayTitle => '📢 Smart Call';

  @override
  String get smartDisplayEmpty => 'No students approved for dismissal at the moment';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get totalStudents => 'Total Students';

  @override
  String get totalRequests => 'Total Requests';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get requestLog => 'Request Log';

  @override
  String get exit => 'Exit';

  @override
  String get statsChart => 'Statistics Chart';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportSuccess => 'Data exported successfully';

  @override
  String get userManagement => 'User Management';

  @override
  String get addUser => 'Add User';

  @override
  String get addNewUser => 'Add New User';

  @override
  String get name => 'Name';

  @override
  String get role => 'Role';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get changeRole => 'Change Role';

  @override
  String get noUsers => 'No users found';

  @override
  String get filterByRole => 'Filter by role';

  @override
  String get all => 'All';

  @override
  String get userAdded => 'User added successfully';

  @override
  String userDeleted(String name) {
    return '$name has been deleted';
  }

  @override
  String get editUser => 'Edit User';

  @override
  String get save => 'Save';

  @override
  String get search => 'Search...';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleAdmin => 'Admin';

  @override
  String userUpdated(String name) {
    return 'User updated successfully $name';
  }

  @override
  String get loginSelectRole => 'Select your role to login';

  @override
  String get roleGate => 'Gate';

  @override
  String get schoolAppTitle => 'School Dismissal System';

  @override
  String get loadingDots => 'Loading...';

  @override
  String get nationalId => 'National ID';

  @override
  String get selectPhoto => 'Select Photo';

  @override
  String get requiredField => 'Required';

  @override
  String get studentAdded => 'Student added successfully';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get dismissalCardTitle => 'Dismissal Card';

  @override
  String get photo => 'Photo';

  @override
  String get requestedBy => 'Requested By';

  @override
  String get requestTime => 'Request Time';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get attachment => 'Attachment';

  @override
  String get qrCodeLabel => 'Pickup QR Code';

  @override
  String get pdfDisclaimerLine1 => 'This document is auto-generated and does not require a signature.';

  @override
  String get pdfDisclaimerLine2 => 'Please present this document at the gate during pickup.';

  @override
  String get errorTryAgain => 'An error occurred. Please try again.';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get lookupsNotReady => 'Lookup data is not ready yet';

  @override
  String get alreadyHasPending => 'Student already has a pending request';

  @override
  String get selectReason => 'Please select a reason';

  @override
  String get requestSent => 'Request sent';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get send => 'Send';

  @override
  String get selectUser => 'Select user';

  @override
  String get refresh => 'Refresh';

  @override
  String get login => 'Log in';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get requestFailed => 'Request Failed To Send';

  @override
  String get sending => 'Sending...';
}
