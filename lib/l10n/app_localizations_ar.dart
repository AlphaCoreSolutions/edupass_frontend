// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome => 'مرحبًا بك 👋';

  @override
  String get settings => 'الإعدادات';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get noStudents => 'لا يوجد أبناء مرتبطين بالحساب';

  @override
  String get addStudent => 'إضافة طالب';

  @override
  String get grade => 'الصف';

  @override
  String get idNumber => 'رقم الهوية';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get latestRequest => 'آخر طلب';

  @override
  String get cancelNotice => 'يمكنك إلغاء الطلب قبل الموافقة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get requestCanceled => 'تم إلغاء الطلب';

  @override
  String get generatePdf => 'توليد بطاقة الانصراف';

  @override
  String get requestDismissal => 'طلب انصراف';

  @override
  String get requestEarlyLeave => 'طلب استئذان';

  @override
  String get requestHistory => 'سجل الطلبات:';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get approved => 'موافقة';

  @override
  String get rejected => 'مرفوض';

  @override
  String get completed => 'تم الانصراف';

  @override
  String get dismissal => 'انصراف';

  @override
  String get earlyLeave => 'استئذان';

  @override
  String get children => 'أبنائي';

  @override
  String get requests => 'الطلبات';

  @override
  String get account => 'الحساب';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get noRequestsYet => 'لا توجد طلبات حتى الآن';

  @override
  String get parentExperimental => 'ولي الأمر (تجريبي)';

  @override
  String get clearRequests => 'مسح كل الطلبات';

  @override
  String get requestsCleared => 'تم مسح الطلبات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get adminPanel => 'لوحة الإدارة';

  @override
  String get studentName => 'الطالبة';

  @override
  String get requestType => 'نوع الطلب';

  @override
  String get requestStatus => 'الحالة';

  @override
  String get reason => 'السبب';

  @override
  String get typeDismissal => 'انصراف';

  @override
  String get typeEarlyLeave => 'استئذان';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusApproved => 'تمت الموافقة';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusCompleted => 'تم الانصراف';

  @override
  String get gateTitle => 'بوابة المدرسة';

  @override
  String get gateNoStudents => 'لا يوجد طالبات جاهزات للخروج';

  @override
  String gateExitSuccess(String name) {
    return '$name خرجت من البوابة ✅';
  }

  @override
  String get gateExitError => 'حدث خطأ أثناء تحديث حالة الطلب';

  @override
  String get exitDone => 'تم الخروج';

  @override
  String get scanQR => 'مسح QR ولي الأمر';

  @override
  String get unknown => 'غير معروف';

  @override
  String get qrInvalid => 'الرمز غير صالح';

  @override
  String get qrNotFound => 'الطلب غير موجود';

  @override
  String get qrNotApproved => 'الطلب ليس في حالة موافقة';

  @override
  String get qrStudentNotFound => 'الطالبة غير موجودة';

  @override
  String get qrConfirmExit => 'تأكيد الخروج';

  @override
  String qrConfirmExitMessage(String name) {
    return 'تأكيد خروج $name من البوابة؟';
  }

  @override
  String qrExitSuccess(String name) {
    return '$name خرجت من البوابة ✅';
  }

  @override
  String get confirm => 'تأكيد';

  @override
  String get supervisorTitle => 'واجهة المشرفة';

  @override
  String get supervisorNoRequests => 'لا توجد طلبات نشطة';

  @override
  String get studentGrade => 'الصف';

  @override
  String get studentId => 'الهوية';

  @override
  String get studentGender => 'الجنس';

  @override
  String get requestReason => 'السبب';

  @override
  String get actionApprove => 'موافقة';

  @override
  String get actionReject => 'رفض';

  @override
  String get actionComplete => 'تم الخروج';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get smartDisplayTitle => '📢 النداء الذكي';

  @override
  String get smartDisplayEmpty => 'لا توجد طالبات تمت الموافقة على خروجهن حاليًا';

  @override
  String get adminDashboard => 'لوحة الإدارة';

  @override
  String get totalStudents => 'عدد الطلاب';

  @override
  String get totalRequests => 'الطلبات الكلية';

  @override
  String get pendingRequests => 'طلبات معلقة';

  @override
  String get requestLog => 'سجل الطلبات';

  @override
  String get exit => 'خروج';

  @override
  String get statsChart => 'الرسم البياني للإحصائيات';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get exportSuccess => 'تم تصدير البيانات بنجاح';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get addNewUser => 'إضافة مستخدم جديد';

  @override
  String get name => 'الاسم';

  @override
  String get role => 'الدور';

  @override
  String get add => 'إضافة';

  @override
  String get delete => 'حذف';

  @override
  String get changeRole => 'تغيير الدور';

  @override
  String get noUsers => 'لا يوجد مستخدمون';

  @override
  String get filterByRole => 'تصفية حسب الدور';

  @override
  String get all => 'الكل';

  @override
  String get userAdded => 'تمت إضافة المستخدم';

  @override
  String userDeleted(String name) {
    return 'تم حذف $name';
  }

  @override
  String get editUser => 'تعديل المستخدم';

  @override
  String get save => 'Save';

  @override
  String get search => 'بحث...';

  @override
  String get roleParent => 'ولي أمر';

  @override
  String get roleSupervisor => 'مشرفة';

  @override
  String get roleAdmin => 'مديرة';

  @override
  String userUpdated(String name) {
    return 'تم تحديث المستخدم بنجاح $name';
  }

  @override
  String get loginSelectRole => 'اختر دورك لتسجيل الدخول';

  @override
  String get roleGate => 'بوابة';

  @override
  String get schoolAppTitle => 'نظام الانصراف المدرسي';

  @override
  String get loadingDots => 'جاري التحميل...';

  @override
  String get nationalId => 'رقم الهوية الوطنية';

  @override
  String get selectPhoto => 'اختيار صورة';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get studentAdded => 'تمت إضافة الطالب';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get dismissalCardTitle => 'بطاقة الانصراف';

  @override
  String get photo => 'الصورة';

  @override
  String get requestedBy => 'مقدم الطلب';

  @override
  String get requestTime => 'وقت تقديم الطلب';

  @override
  String get currentStatus => 'الحالة الحالية';

  @override
  String get attachment => 'المرفق';

  @override
  String get qrCodeLabel => 'رمز الاستلام (QR)';

  @override
  String get pdfDisclaimerLine1 => 'هذا المستند يولد آليًا ولا يحتاج إلى توقيع.';

  @override
  String get pdfDisclaimerLine2 => 'يرجى إبراز هذا المستند عند الخروج من البوابة.';

  @override
  String get errorTryAgain => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get areYouSure => 'هل أنت متأكد؟';

  @override
  String get lookupsNotReady => 'لم يتم تحميل بيانات القائمة بعد';

  @override
  String get alreadyHasPending => 'للطالبة طلب قيد الانتظار بالفعل';

  @override
  String get selectReason => 'يرجى اختيار سبب الاستئذان';

  @override
  String get requestSent => 'تم إرسال الطلب';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get send => 'إرسال';

  @override
  String get selectUser => 'اختر المستخدم';

  @override
  String get refresh => 'تحديث';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get continueWithoutAccount => 'متابعة بدون حساب';

  @override
  String get requestFailed => 'فشل إرسال الطلب';

  @override
  String get sending => 'جارٍ الإرسال…';
}
