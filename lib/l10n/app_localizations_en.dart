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

  @override
  String get filtersTitle => 'Filters';

  @override
  String get selectStudent => 'Select student';

  @override
  String get status => 'Status';

  @override
  String get resetFilters => 'Reset';

  @override
  String get adminShortcutsBusesTitle => 'Official Buses';

  @override
  String get adminShortcutsBusesSubtitle => 'Manage buses, schedules and fees';

  @override
  String get adminShortcutsBusRequestsTitle => 'Bus Join Requests';

  @override
  String get adminShortcutsBusRequestsSubtitle => 'Review, approve/reject and activate paid';

  @override
  String get busesStatsTitle => 'Bus Analytics';

  @override
  String get neighborhood => 'Neighborhood';

  @override
  String get supervisorId => 'Supervisor ID';

  @override
  String get downloadCsv => 'Export CSV';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get currencySarShort => 'SAR';

  @override
  String get monthlyFeeShort => 'SAR/month';

  @override
  String get busGoTime => 'Go';

  @override
  String get busReturnTime => 'Return';

  @override
  String get busesCountFiltered => 'Buses (filtered)';

  @override
  String get awaitingPaymentCount => 'Awaiting payment';

  @override
  String get paidActiveCount => 'Active (paid)';

  @override
  String get estimatedMonthlyRevenue => 'Estimated monthly revenue';

  @override
  String get noBusChartData => 'No bus data to chart';

  @override
  String get activeSubscribersPerBus => 'Active subscribers per bus';

  @override
  String get awaitingPerBus => 'Awaiting payment per bus';

  @override
  String get activeShort => 'Active';

  @override
  String get awaitingShort => 'Awaiting';

  @override
  String get quickDetails => 'Quick details';

  @override
  String get activeSubscribers => 'Active subscribers';

  @override
  String get awaitingPayment => 'Awaiting payment';

  @override
  String get noItems => 'No items';

  @override
  String get parent => 'Parent';

  @override
  String get reference => 'Ref';

  @override
  String get exportBusCsv => 'Export bus enrollments CSV';

  @override
  String get busRequestsTitle => 'Bus Join Requests';

  @override
  String get busStatusPending => 'Pending';

  @override
  String get busStatusApprovedAwaitingPayment => 'Approved, awaiting payment';

  @override
  String get busStatusPaid => 'Active (paid)';

  @override
  String get busStatusRejected => 'Rejected';

  @override
  String get busStatusCancelled => 'Cancelled';

  @override
  String get searchStudentOrBus => 'Search by student / bus';

  @override
  String get clear => 'Clear';

  @override
  String get noResults => 'No results';

  @override
  String get request => 'Request';

  @override
  String get paymentRef => 'Payment ref';

  @override
  String get paymentRefHint => 'e.g., TXN-12345';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get activatePaidManually => 'Activate manually (paid)';

  @override
  String get rejectAfterApproval => 'Reject after approval';

  @override
  String get noAction => 'No action';

  @override
  String get busManageTitle => 'Official Bus Management';

  @override
  String get addedBuses => 'Added buses';

  @override
  String get noBuses => 'No buses added yet';

  @override
  String get addBusHint => 'Use the form below to add a new bus';

  @override
  String get edit => 'Edit';

  @override
  String get addBus => 'Add bus';

  @override
  String get editBus => 'Edit bus';

  @override
  String get editMode => 'Edit mode';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get busName => 'Bus name';

  @override
  String get routeDescription => 'Route description';

  @override
  String get goTimeLabel => 'Go';

  @override
  String get returnTimeLabel => 'Return';

  @override
  String get monthlyFee => 'Monthly fee';

  @override
  String get busSupervisorId => 'Bus supervisor ID';

  @override
  String get required => 'Required';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get invalidTimeFormat => 'Invalid format, e.g. 06:45';

  @override
  String get invalidTime => 'Invalid time';

  @override
  String get selectOperatingDays => 'Please select operating days';

  @override
  String get addedSuccess => 'Added successfully';

  @override
  String get savedSuccess => 'Saved successfully';

  @override
  String get clearForm => 'Clear form';

  @override
  String get pickTime => 'Pick time';

  @override
  String get deleteBusTitle => 'Delete bus';

  @override
  String deleteBusConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String get loadedForEdit => 'Bus data loaded for editing';

  @override
  String get weekdaySun => 'Sunday';

  @override
  String get weekdayMon => 'Monday';

  @override
  String get weekdayTue => 'Tuesday';

  @override
  String get weekdayWed => 'Wednesday';

  @override
  String get weekdayThu => 'Thursday';

  @override
  String get weekdayFri => 'Friday';

  @override
  String get weekdaySat => 'Saturday';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get parentHomeTitle => 'My Children';

  @override
  String get currentTransport => 'Current Transport';

  @override
  String get noBusAssigned => 'No bus assigned yet';

  @override
  String get joinBus => 'Join a Bus';

  @override
  String get join => 'Join';

  @override
  String get parentBusJoinTitle => 'School Buses';

  @override
  String get searchHint => 'Search for a bus…';

  @override
  String get reset => 'Reset';

  @override
  String get busStatusAwaitPayment => 'Awaiting payment';

  @override
  String get busStatusActive => 'Active';

  @override
  String get payAndActivate => 'Pay & Activate';

  @override
  String get refreshShort => 'Refresh';

  @override
  String get parentBusesTitle => 'School Buses';

  @override
  String get parentBusesSubtitle => 'Browse buses, request to join, manage payments';

  @override
  String get authorizedPeopleTitle => 'Authorized Pickups';

  @override
  String get authorizedPeopleSubtitle => 'Add and manage trusted people to pick up your child';

  @override
  String get active => 'Active';

  @override
  String get manage => 'Manage';

  @override
  String authorizedPeopleCount(int count) {
    return 'Authorized people: $count';
  }

  @override
  String get requestJoinBus => 'Request to Join';

  @override
  String get myBusRequests => 'My Bus Requests';

  @override
  String get paymentActivated => 'Payment completed. Enrollment activated.';

  @override
  String get statusAwaitingPayment => 'Awaiting Payment';

  @override
  String get statusActive => 'Active';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get inactive => 'Inactive';

  @override
  String get noActiveBus => 'No active bus';

  @override
  String get addAuthorizedPerson => 'Add Authorized Person';

  @override
  String deleteConfirmName(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get deletedSuccess => 'Deleted successfully';

  @override
  String get phone => 'Phone';

  @override
  String get fullName => 'Full Name';
}
