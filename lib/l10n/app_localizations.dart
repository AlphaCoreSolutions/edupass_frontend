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
