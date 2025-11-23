import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome 👋'**
  String get welcome;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @noStudents.
  ///
  /// In en, this message translates to:
  /// **'No linked students found'**
  String get noStudents;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudent;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @latestRequest.
  ///
  /// In en, this message translates to:
  /// **'Latest Request'**
  String get latestRequest;

  /// No description provided for @cancelNotice.
  ///
  /// In en, this message translates to:
  /// **'You can cancel the request before approval'**
  String get cancelNotice;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @requestCanceled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get requestCanceled;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate Dismissal Card'**
  String get generatePdf;

  /// No description provided for @requestDismissal.
  ///
  /// In en, this message translates to:
  /// **'Request Dismissal'**
  String get requestDismissal;

  /// No description provided for @requestEarlyLeave.
  ///
  /// In en, this message translates to:
  /// **'Request Early Leave'**
  String get requestEarlyLeave;

  /// No description provided for @requestHistory.
  ///
  /// In en, this message translates to:
  /// **'Request History:'**
  String get requestHistory;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get completed;

  /// No description provided for @dismissal.
  ///
  /// In en, this message translates to:
  /// **'Dismissal'**
  String get dismissal;

  /// No description provided for @earlyLeave.
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get earlyLeave;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @parentExperimental.
  ///
  /// In en, this message translates to:
  /// **'Parent (Demo)'**
  String get parentExperimental;

  /// No description provided for @clearRequests.
  ///
  /// In en, this message translates to:
  /// **'Clear All Requests'**
  String get clearRequests;

  /// No description provided for @requestsCleared.
  ///
  /// In en, this message translates to:
  /// **'Requests cleared'**
  String get requestsCleared;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @studentName.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentName;

  /// No description provided for @requestType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestType;

  /// No description provided for @requestStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get requestStatus;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @typeDismissal.
  ///
  /// In en, this message translates to:
  /// **'Dismissal'**
  String get typeDismissal;

  /// No description provided for @typeEarlyLeave.
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get typeEarlyLeave;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @gateTitle.
  ///
  /// In en, this message translates to:
  /// **'School Gate'**
  String get gateTitle;

  /// No description provided for @gateNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students ready to exit'**
  String get gateNoStudents;

  /// Message shown when a student exits through the gate; includes the student's name
  ///
  /// In en, this message translates to:
  /// **'{name} has exited through the gate ✅'**
  String gateExitSuccess(String name);

  /// No description provided for @gateExitError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating request status'**
  String get gateExitError;

  /// No description provided for @exitDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Exit'**
  String get exitDone;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan Parent QR'**
  String get scanQR;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @qrInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get qrInvalid;

  /// No description provided for @qrNotFound.
  ///
  /// In en, this message translates to:
  /// **'Request not found'**
  String get qrNotFound;

  /// No description provided for @qrNotApproved.
  ///
  /// In en, this message translates to:
  /// **'Request is not approved'**
  String get qrNotApproved;

  /// No description provided for @qrStudentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Student not found'**
  String get qrStudentNotFound;

  /// No description provided for @qrConfirmExit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get qrConfirmExit;

  /// Confirmation message for student exit; includes the student's name
  ///
  /// In en, this message translates to:
  /// **'Confirm that {name} has exited the gate?'**
  String qrConfirmExitMessage(String name);

  /// Message shown when a student successfully exits the gate; includes the student's name
  ///
  /// In en, this message translates to:
  /// **'{name} has exited the gate ✅'**
  String qrExitSuccess(String name);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @supervisorTitle.
  ///
  /// In en, this message translates to:
  /// **'Supervisor Dashboard'**
  String get supervisorTitle;

  /// No description provided for @supervisorNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No active requests'**
  String get supervisorNoRequests;

  /// No description provided for @studentGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get studentGrade;

  /// No description provided for @studentId.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get studentId;

  /// No description provided for @studentGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get studentGender;

  /// No description provided for @requestReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get requestReason;

  /// No description provided for @actionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get actionApprove;

  /// No description provided for @actionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get actionReject;

  /// No description provided for @actionComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get actionComplete;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @smartDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'📢 Smart Call'**
  String get smartDisplayTitle;

  /// No description provided for @smartDisplayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No students approved for dismissal at the moment'**
  String get smartDisplayEmpty;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @totalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudents;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get totalRequests;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @requestLog.
  ///
  /// In en, this message translates to:
  /// **'Request Log'**
  String get requestLog;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @statsChart.
  ///
  /// In en, this message translates to:
  /// **'Statistics Chart'**
  String get statsChart;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRole;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsers;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by role'**
  String get filterByRole;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @userAdded.
  ///
  /// In en, this message translates to:
  /// **'User added successfully'**
  String get userAdded;

  /// Message shown when a user is deleted; includes the user's name
  ///
  /// In en, this message translates to:
  /// **'{name} has been deleted'**
  String userDeleted(String name);

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @roleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get roleSupervisor;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// Message shown when a user is updated; includes the user's name
  ///
  /// In en, this message translates to:
  /// **'User updated successfully {name}'**
  String userUpdated(String name);

  /// No description provided for @loginSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role to login'**
  String get loginSelectRole;

  /// No description provided for @roleGate.
  ///
  /// In en, this message translates to:
  /// **'Gate'**
  String get roleGate;

  /// No description provided for @schoolAppTitle.
  ///
  /// In en, this message translates to:
  /// **'School Dismissal System'**
  String get schoolAppTitle;

  /// No description provided for @loadingDots.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingDots;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @studentAdded.
  ///
  /// In en, this message translates to:
  /// **'Student added successfully'**
  String get studentAdded;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @dismissalCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dismissal Card'**
  String get dismissalCardTitle;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested By'**
  String get requestedBy;

  /// No description provided for @requestTime.
  ///
  /// In en, this message translates to:
  /// **'Request Time'**
  String get requestTime;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @qrCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup QR Code'**
  String get qrCodeLabel;

  /// No description provided for @pdfDisclaimerLine1.
  ///
  /// In en, this message translates to:
  /// **'This document is auto-generated and does not require a signature.'**
  String get pdfDisclaimerLine1;

  /// No description provided for @pdfDisclaimerLine2.
  ///
  /// In en, this message translates to:
  /// **'Please present this document at the gate during pickup.'**
  String get pdfDisclaimerLine2;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorTryAgain;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @lookupsNotReady.
  ///
  /// In en, this message translates to:
  /// **'Lookup data is not ready yet'**
  String get lookupsNotReady;

  /// No description provided for @alreadyHasPending.
  ///
  /// In en, this message translates to:
  /// **'Student already has a pending request'**
  String get alreadyHasPending;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get selectReason;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @selectUser.
  ///
  /// In en, this message translates to:
  /// **'Select user'**
  String get selectUser;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request Failed To Send'**
  String get requestFailed;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @selectStudent.
  ///
  /// In en, this message translates to:
  /// **'Select student'**
  String get selectStudent;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @adminShortcutsBusesTitle.
  ///
  /// In en, this message translates to:
  /// **'Official Buses'**
  String get adminShortcutsBusesTitle;

  /// No description provided for @adminShortcutsBusesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage buses, schedules and fees'**
  String get adminShortcutsBusesSubtitle;

  /// No description provided for @adminShortcutsBusRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bus Join Requests'**
  String get adminShortcutsBusRequestsTitle;

  /// No description provided for @adminShortcutsBusRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review, approve/reject and activate paid'**
  String get adminShortcutsBusRequestsSubtitle;

  /// No description provided for @busesStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bus Analytics'**
  String get busesStatsTitle;

  /// No description provided for @neighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhood;

  /// No description provided for @supervisorId.
  ///
  /// In en, this message translates to:
  /// **'Supervisor ID'**
  String get supervisorId;

  /// No description provided for @downloadCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get downloadCsv;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @currencySarShort.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currencySarShort;

  /// No description provided for @monthlyFeeShort.
  ///
  /// In en, this message translates to:
  /// **'SAR/month'**
  String get monthlyFeeShort;

  /// No description provided for @busGoTime.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get busGoTime;

  /// No description provided for @busReturnTime.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get busReturnTime;

  /// No description provided for @busesCountFiltered.
  ///
  /// In en, this message translates to:
  /// **'Buses (filtered)'**
  String get busesCountFiltered;

  /// No description provided for @awaitingPaymentCount.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get awaitingPaymentCount;

  /// No description provided for @paidActiveCount.
  ///
  /// In en, this message translates to:
  /// **'Active (paid)'**
  String get paidActiveCount;

  /// No description provided for @estimatedMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Estimated monthly revenue'**
  String get estimatedMonthlyRevenue;

  /// No description provided for @noBusChartData.
  ///
  /// In en, this message translates to:
  /// **'No bus data to chart'**
  String get noBusChartData;

  /// No description provided for @activeSubscribersPerBus.
  ///
  /// In en, this message translates to:
  /// **'Active subscribers per bus'**
  String get activeSubscribersPerBus;

  /// No description provided for @awaitingPerBus.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment per bus'**
  String get awaitingPerBus;

  /// No description provided for @activeShort.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeShort;

  /// No description provided for @awaitingShort.
  ///
  /// In en, this message translates to:
  /// **'Awaiting'**
  String get awaitingShort;

  /// No description provided for @quickDetails.
  ///
  /// In en, this message translates to:
  /// **'Quick details'**
  String get quickDetails;

  /// No description provided for @activeSubscribers.
  ///
  /// In en, this message translates to:
  /// **'Active subscribers'**
  String get activeSubscribers;

  /// No description provided for @awaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get awaitingPayment;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get reference;

  /// No description provided for @exportBusCsv.
  ///
  /// In en, this message translates to:
  /// **'Export bus enrollments CSV'**
  String get exportBusCsv;

  /// No description provided for @busRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bus Join Requests'**
  String get busRequestsTitle;

  /// No description provided for @busStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get busStatusPending;

  /// No description provided for @busStatusApprovedAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Approved, awaiting payment'**
  String get busStatusApprovedAwaitingPayment;

  /// No description provided for @busStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Active (paid)'**
  String get busStatusPaid;

  /// No description provided for @busStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get busStatusRejected;

  /// No description provided for @busStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get busStatusCancelled;

  /// No description provided for @searchStudentOrBus.
  ///
  /// In en, this message translates to:
  /// **'Search by student / bus'**
  String get searchStudentOrBus;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @paymentRef.
  ///
  /// In en, this message translates to:
  /// **'Payment ref'**
  String get paymentRef;

  /// No description provided for @paymentRefHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., TXN-12345'**
  String get paymentRefHint;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @activatePaidManually.
  ///
  /// In en, this message translates to:
  /// **'Activate manually (paid)'**
  String get activatePaidManually;

  /// No description provided for @rejectAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Reject after approval'**
  String get rejectAfterApproval;

  /// No description provided for @noAction.
  ///
  /// In en, this message translates to:
  /// **'No action'**
  String get noAction;

  /// No description provided for @busManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Official Bus Management'**
  String get busManageTitle;

  /// No description provided for @addedBuses.
  ///
  /// In en, this message translates to:
  /// **'Added buses'**
  String get addedBuses;

  /// No description provided for @noBuses.
  ///
  /// In en, this message translates to:
  /// **'No buses added yet'**
  String get noBuses;

  /// No description provided for @addBusHint.
  ///
  /// In en, this message translates to:
  /// **'Use the form below to add a new bus'**
  String get addBusHint;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @addBus.
  ///
  /// In en, this message translates to:
  /// **'Add bus'**
  String get addBus;

  /// No description provided for @editBus.
  ///
  /// In en, this message translates to:
  /// **'Edit bus'**
  String get editBus;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit mode'**
  String get editMode;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @busName.
  ///
  /// In en, this message translates to:
  /// **'Bus name'**
  String get busName;

  /// No description provided for @routeDescription.
  ///
  /// In en, this message translates to:
  /// **'Route description'**
  String get routeDescription;

  /// No description provided for @goTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get goTimeLabel;

  /// No description provided for @returnTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnTimeLabel;

  /// No description provided for @monthlyFee.
  ///
  /// In en, this message translates to:
  /// **'Monthly fee'**
  String get monthlyFee;

  /// No description provided for @busSupervisorId.
  ///
  /// In en, this message translates to:
  /// **'Bus supervisor ID'**
  String get busSupervisorId;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalidValue;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @invalidTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format, e.g. 06:45'**
  String get invalidTimeFormat;

  /// No description provided for @invalidTime.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get invalidTime;

  /// No description provided for @selectOperatingDays.
  ///
  /// In en, this message translates to:
  /// **'Please select operating days'**
  String get selectOperatingDays;

  /// No description provided for @addedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get addedSuccess;

  /// No description provided for @savedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccess;

  /// No description provided for @clearForm.
  ///
  /// In en, this message translates to:
  /// **'Clear form'**
  String get clearForm;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTime;

  /// No description provided for @deleteBusTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete bus'**
  String get deleteBusTitle;

  /// No description provided for @deleteBusConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteBusConfirm(String name);

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @loadedForEdit.
  ///
  /// In en, this message translates to:
  /// **'Bus data loaded for editing'**
  String get loadedForEdit;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySat;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @parentHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Children'**
  String get parentHomeTitle;

  /// No description provided for @currentTransport.
  ///
  /// In en, this message translates to:
  /// **'Current Transport'**
  String get currentTransport;

  /// No description provided for @noBusAssigned.
  ///
  /// In en, this message translates to:
  /// **'No bus assigned yet'**
  String get noBusAssigned;

  /// No description provided for @joinBus.
  ///
  /// In en, this message translates to:
  /// **'Join a Bus'**
  String get joinBus;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @parentBusJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'School Buses'**
  String get parentBusJoinTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a bus…'**
  String get searchHint;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @busStatusAwaitPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get busStatusAwaitPayment;

  /// No description provided for @busStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get busStatusActive;

  /// No description provided for @payAndActivate.
  ///
  /// In en, this message translates to:
  /// **'Pay & Activate'**
  String get payAndActivate;

  /// No description provided for @refreshShort.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshShort;

  /// No description provided for @parentBusesTitle.
  ///
  /// In en, this message translates to:
  /// **'School Buses'**
  String get parentBusesTitle;

  /// No description provided for @parentBusesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse buses, request to join, manage payments'**
  String get parentBusesSubtitle;

  /// No description provided for @authorizedPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Authorized Pickups'**
  String get authorizedPeopleTitle;

  /// No description provided for @authorizedPeopleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and manage trusted people to pick up your child'**
  String get authorizedPeopleSubtitle;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// Shows how many authorized pickup people are linked to the student
  ///
  /// In en, this message translates to:
  /// **'Authorized people: {count}'**
  String authorizedPeopleCount(int count);

  /// No description provided for @requestJoinBus.
  ///
  /// In en, this message translates to:
  /// **'Request to Join'**
  String get requestJoinBus;

  /// No description provided for @myBusRequests.
  ///
  /// In en, this message translates to:
  /// **'My Bus Requests'**
  String get myBusRequests;

  /// No description provided for @paymentActivated.
  ///
  /// In en, this message translates to:
  /// **'Payment completed. Enrollment activated.'**
  String get paymentActivated;

  /// No description provided for @statusAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get statusAwaitingPayment;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @noActiveBus.
  ///
  /// In en, this message translates to:
  /// **'No active bus'**
  String get noActiveBus;

  /// No description provided for @addAuthorizedPerson.
  ///
  /// In en, this message translates to:
  /// **'Add Authorized Person'**
  String get addAuthorizedPerson;

  /// No description provided for @deleteConfirmName.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteConfirmName(String name);

  /// No description provided for @deletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccess;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get pleaseLogin;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
