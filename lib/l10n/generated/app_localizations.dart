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
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'ريبال'**
  String get appTitle;

  /// No description provided for @common_cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get common_confirm;

  /// No description provided for @common_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get common_edit;

  /// No description provided for @common_save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get common_save;

  /// No description provided for @common_saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get common_saveChanges;

  /// No description provided for @common_close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In ar, this message translates to:
  /// **'العودة'**
  String get common_back;

  /// No description provided for @common_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In ar, this message translates to:
  /// **'نجح'**
  String get common_success;

  /// No description provided for @common_warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get common_warning;

  /// No description provided for @common_search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get common_search;

  /// No description provided for @common_filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get common_filter;

  /// No description provided for @common_no_data.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get common_no_data;

  /// No description provided for @common_no_results.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get common_no_results;

  /// No description provided for @common_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get common_all;

  /// No description provided for @common_optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get common_optional;

  /// No description provided for @common_required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get common_required;

  /// No description provided for @common_status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get common_status;

  /// No description provided for @common_date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get common_date;

  /// No description provided for @common_time.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get common_time;

  /// No description provided for @common_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get common_name;

  /// No description provided for @common_description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get common_description;

  /// No description provided for @common_create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get common_create;

  /// No description provided for @common_add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get common_add;

  /// No description provided for @common_remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get common_remove;

  /// No description provided for @common_view.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get common_view;

  /// No description provided for @common_details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get common_details;

  /// No description provided for @common_actions.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات'**
  String get common_actions;

  /// No description provided for @common_members.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء'**
  String get common_members;

  /// No description provided for @common_member.
  ///
  /// In ar, this message translates to:
  /// **'عضو'**
  String get common_member;

  /// No description provided for @common_total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get common_total;

  /// No description provided for @common_info.
  ///
  /// In ar, this message translates to:
  /// **'معلومات'**
  String get common_info;

  /// No description provided for @common_copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get common_copy;

  /// No description provided for @common_copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get common_copied;

  /// No description provided for @common_yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get common_no;

  /// No description provided for @common_from.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get common_from;

  /// No description provided for @common_to.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get common_to;

  /// No description provided for @common_at.
  ///
  /// In ar, this message translates to:
  /// **'في'**
  String get common_at;

  /// No description provided for @common_or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get common_or;

  /// No description provided for @common_and.
  ///
  /// In ar, this message translates to:
  /// **'و'**
  String get common_and;

  /// No description provided for @common_selectAll.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل'**
  String get common_selectAll;

  /// No description provided for @common_unselectAll.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التحديد'**
  String get common_unselectAll;

  /// No description provided for @common_noSelection.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحديد'**
  String get common_noSelection;

  /// No description provided for @common_done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get common_done;

  /// No description provided for @common_next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get common_next;

  /// No description provided for @common_previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get common_previous;

  /// No description provided for @common_finish.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get common_finish;

  /// No description provided for @common_skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get common_skip;

  /// No description provided for @common_update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get common_update;

  /// No description provided for @common_refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get common_refresh;

  /// No description provided for @common_confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get common_confirmDelete;

  /// No description provided for @common_errorUserNotFound.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم غير موجود'**
  String get common_errorUserNotFound;

  /// No description provided for @profile_title.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile_title;

  /// No description provided for @profile_fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get profile_fullName;

  /// No description provided for @profile_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get profile_email;

  /// No description provided for @profile_role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get profile_role;

  /// No description provided for @profile_darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get profile_darkMode;

  /// No description provided for @profile_editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get profile_editProfile;

  /// No description provided for @profile_changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get profile_changePassword;

  /// No description provided for @profile_logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get profile_logout;

  /// No description provided for @profile_logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get profile_logoutConfirm;

  /// No description provided for @profile_changesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات بنجاح'**
  String get profile_changesSaved;

  /// No description provided for @profile_tapToChangePhoto.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لتغيير الصورة'**
  String get profile_tapToChangePhoto;

  /// No description provided for @profile_uploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل رفع الصورة'**
  String get profile_uploadFailed;

  /// No description provided for @profile_language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get profile_language;

  /// No description provided for @profile_languageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة التطبيق'**
  String get profile_languageSubtitle;

  /// No description provided for @profile_saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get profile_saveChanges;

  /// No description provided for @language_title.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language_title;

  /// No description provided for @language_arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get language_arabic;

  /// No description provided for @language_english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_arabicSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم اللغة العربية'**
  String get language_arabicSubtitle;

  /// No description provided for @language_englishSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'Use English language'**
  String get language_englishSubtitle;

  /// No description provided for @theme_title.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get theme_title;

  /// No description provided for @theme_system.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get theme_system;

  /// No description provided for @theme_systemSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يتبع إعدادات الجهاز'**
  String get theme_systemSubtitle;

  /// No description provided for @theme_light.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get theme_light;

  /// No description provided for @theme_lightSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'دائماً فاتح'**
  String get theme_lightSubtitle;

  /// No description provided for @theme_dark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get theme_dark;

  /// No description provided for @theme_darkSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'دائماً داكن'**
  String get theme_darkSubtitle;

  /// No description provided for @auth_login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get auth_login;

  /// No description provided for @auth_loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بياناتك للدخول إلى حسابك'**
  String get auth_loginSubtitle;

  /// No description provided for @auth_register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get auth_register;

  /// No description provided for @auth_registerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بياناتك لإنشاء حساب جديد'**
  String get auth_registerSubtitle;

  /// No description provided for @auth_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get auth_email;

  /// No description provided for @auth_emailHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني'**
  String get auth_emailHint;

  /// No description provided for @auth_emailRequired.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get auth_emailRequired;

  /// No description provided for @auth_emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get auth_emailInvalid;

  /// No description provided for @auth_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get auth_password;

  /// No description provided for @auth_passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get auth_passwordHint;

  /// No description provided for @auth_passwordRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مطلوبة'**
  String get auth_passwordRequired;

  /// No description provided for @auth_passwordMinLength.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 8 أحرف على الأقل'**
  String get auth_passwordMinLength;

  /// No description provided for @auth_passwordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير متطابقة'**
  String get auth_passwordMismatch;

  /// No description provided for @auth_passwordCurrent.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get auth_passwordCurrent;

  /// No description provided for @auth_passwordCurrentHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور الحالية'**
  String get auth_passwordCurrentHint;

  /// No description provided for @auth_passwordCurrentRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية مطلوبة'**
  String get auth_passwordCurrentRequired;

  /// No description provided for @auth_passwordNew.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get auth_passwordNew;

  /// No description provided for @auth_passwordNewHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور الجديدة'**
  String get auth_passwordNewHint;

  /// No description provided for @auth_passwordNewRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة مطلوبة'**
  String get auth_passwordNewRequired;

  /// No description provided for @auth_passwordConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get auth_passwordConfirm;

  /// No description provided for @auth_passwordConfirmHint.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال كلمة المرور الجديدة'**
  String get auth_passwordConfirmHint;

  /// No description provided for @auth_passwordConfirmRequired.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور مطلوب'**
  String get auth_passwordConfirmRequired;

  /// No description provided for @auth_passwordChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get auth_passwordChanged;

  /// No description provided for @auth_firstName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get auth_firstName;

  /// No description provided for @auth_firstNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الاسم الأول'**
  String get auth_firstNameHint;

  /// No description provided for @auth_firstNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول مطلوب'**
  String get auth_firstNameRequired;

  /// No description provided for @auth_lastName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العائلة'**
  String get auth_lastName;

  /// No description provided for @auth_lastNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم العائلة'**
  String get auth_lastNameHint;

  /// No description provided for @auth_lastNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم العائلة مطلوب'**
  String get auth_lastNameRequired;

  /// No description provided for @auth_invitationCode.
  ///
  /// In ar, this message translates to:
  /// **'كود الدعوة'**
  String get auth_invitationCode;

  /// No description provided for @auth_invitationCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كود الدعوة'**
  String get auth_invitationCodeHint;

  /// No description provided for @auth_invitationCodeRequired.
  ///
  /// In ar, this message translates to:
  /// **'كود الدعوة مطلوب'**
  String get auth_invitationCodeRequired;

  /// No description provided for @auth_haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get auth_haveAccount;

  /// No description provided for @auth_noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get auth_noAccount;

  /// No description provided for @auth_verifyEmail.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من البريد الإلكتروني'**
  String get auth_verifyEmail;

  /// No description provided for @auth_verifyEmailSent.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رسالة تحقق إلى'**
  String get auth_verifyEmailSent;

  /// No description provided for @auth_verifyEmailCheck.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني'**
  String get auth_verifyEmailCheck;

  /// No description provided for @auth_verifyEmailMessage.
  ///
  /// In ar, this message translates to:
  /// **'يرجى النقر على الرابط في الرسالة للتحقق من حسابك'**
  String get auth_verifyEmailMessage;

  /// No description provided for @auth_verifyEmailWaiting.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار التحقق...'**
  String get auth_verifyEmailWaiting;

  /// No description provided for @auth_verifyEmailResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرسالة'**
  String get auth_verifyEmailResend;

  /// No description provided for @auth_verifyEmailResendCooldown.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد'**
  String get auth_verifyEmailResendCooldown;

  /// No description provided for @auth_verifyEmailSeconds.
  ///
  /// In ar, this message translates to:
  /// **'ثانية'**
  String get auth_verifyEmailSeconds;

  /// No description provided for @auth_verifyEmailBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة لتسجيل الدخول'**
  String get auth_verifyEmailBack;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get auth_forgotPassword;

  /// No description provided for @nav_home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get nav_home;

  /// No description provided for @nav_tasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get nav_tasks;

  /// No description provided for @nav_myTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهامي'**
  String get nav_myTasks;

  /// No description provided for @nav_teamTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهام الفريق'**
  String get nav_teamTasks;

  /// No description provided for @nav_controlPanel.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get nav_controlPanel;

  /// No description provided for @nav_profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get nav_profile;

  /// No description provided for @nav_notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get nav_notifications;

  /// No description provided for @nav_statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get nav_statistics;

  /// No description provided for @nav_settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get nav_settings;

  /// No description provided for @task_title.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة'**
  String get task_title;

  /// No description provided for @task_titleHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان المهمة'**
  String get task_titleHint;

  /// No description provided for @task_titleRequired.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة مطلوب'**
  String get task_titleRequired;

  /// No description provided for @task_description.
  ///
  /// In ar, this message translates to:
  /// **'وصف المهمة'**
  String get task_description;

  /// No description provided for @task_descriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل وصف المهمة (اختياري)'**
  String get task_descriptionHint;

  /// No description provided for @task_descriptionOptional.
  ///
  /// In ar, this message translates to:
  /// **'وصف المهمة (اختياري)'**
  String get task_descriptionOptional;

  /// No description provided for @task_create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مهمة'**
  String get task_create;

  /// No description provided for @task_createNew.
  ///
  /// In ar, this message translates to:
  /// **'مهمة جديدة'**
  String get task_createNew;

  /// No description provided for @task_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المهمة'**
  String get task_edit;

  /// No description provided for @task_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة'**
  String get task_delete;

  /// No description provided for @task_deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get task_deleteConfirm;

  /// No description provided for @task_details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المهمة'**
  String get task_details;

  /// No description provided for @task_manage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المهام'**
  String get task_manage;

  /// No description provided for @task_publish.
  ///
  /// In ar, this message translates to:
  /// **'نشر المهمة'**
  String get task_publish;

  /// No description provided for @task_publishToday.
  ///
  /// In ar, this message translates to:
  /// **'نشر لليوم فقط'**
  String get task_publishToday;

  /// No description provided for @task_publishRecurring.
  ///
  /// In ar, this message translates to:
  /// **'نشر كمهمة متكررة'**
  String get task_publishRecurring;

  /// No description provided for @task_archive.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المهمة'**
  String get task_archive;

  /// No description provided for @task_unarchive.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الأرشفة'**
  String get task_unarchive;

  /// No description provided for @task_stopRecurring.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف المهمة المتكررة'**
  String get task_stopRecurring;

  /// No description provided for @task_stopRecurringConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم أرشفة هذه المهمة ولن يتم نشرها للموظفين حتى تقوم بإعادة تفعيلها من لوحة التحكم في قسم الأرشيف.'**
  String get task_stopRecurringConfirm;

  /// No description provided for @task_stopArchive.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف وأرشفة'**
  String get task_stopArchive;

  /// No description provided for @task_createdSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المهمة بنجاح'**
  String get task_createdSuccess;

  /// No description provided for @task_updatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المهمة بنجاح'**
  String get task_updatedSuccess;

  /// No description provided for @task_deletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المهمة بنجاح'**
  String get task_deletedSuccess;

  /// No description provided for @task_archivedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم أرشفة المهمة بنجاح'**
  String get task_archivedSuccess;

  /// No description provided for @task_publishedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر المهمة بنجاح'**
  String get task_publishedSuccess;

  /// No description provided for @task_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل المهمة'**
  String get task_loadError;

  /// No description provided for @task_noTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام'**
  String get task_noTasks;

  /// No description provided for @task_noTasksToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام اليوم'**
  String get task_noTasksToday;

  /// No description provided for @task_noTasksTodaySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعيين أي مهام لهذا اليوم'**
  String get task_noTasksTodaySubtitle;

  /// No description provided for @task_noTasksAssigned.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعيين أي مهام لك'**
  String get task_noTasksAssigned;

  /// No description provided for @task_today.
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get task_today;

  /// No description provided for @task_todayTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهامك لهذا اليوم'**
  String get task_todayTasks;

  /// No description provided for @task_progress.
  ///
  /// In ar, this message translates to:
  /// **'معدل الإنجاز'**
  String get task_progress;

  /// No description provided for @task_completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get task_completed;

  /// No description provided for @task_pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get task_pending;

  /// No description provided for @task_overdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخرة'**
  String get task_overdue;

  /// No description provided for @task_statusDone.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get task_statusDone;

  /// No description provided for @task_statusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get task_statusPending;

  /// No description provided for @task_statusOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get task_statusOverdue;

  /// No description provided for @task_statusApologized.
  ///
  /// In ar, this message translates to:
  /// **'معتذر'**
  String get task_statusApologized;

  /// No description provided for @task_statusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get task_statusActive;

  /// No description provided for @task_statusArchived.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشفة'**
  String get task_statusArchived;

  /// No description provided for @task_loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المهمة...'**
  String get task_loading;

  /// No description provided for @task_recurring.
  ///
  /// In ar, this message translates to:
  /// **'مهمة متكررة'**
  String get task_recurring;

  /// No description provided for @task_recurringLabel.
  ///
  /// In ar, this message translates to:
  /// **'إعادة جدولة المهمة يومياً'**
  String get task_recurringLabel;

  /// No description provided for @task_once.
  ///
  /// In ar, this message translates to:
  /// **'لمرة واحدة'**
  String get task_once;

  /// No description provided for @task_attachmentRequired.
  ///
  /// In ar, this message translates to:
  /// **'المرفق مطلوب'**
  String get task_attachmentRequired;

  /// No description provided for @task_attachmentRequiredSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يجب على المكلفين إرفاق ملف عند إتمام المهمة'**
  String get task_attachmentRequiredSubtitle;

  /// No description provided for @task_attachmentUpload.
  ///
  /// In ar, this message translates to:
  /// **'رفع مرفق'**
  String get task_attachmentUpload;

  /// No description provided for @task_attachmentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع الملف بنجاح'**
  String get task_attachmentUploaded;

  /// No description provided for @task_attachmentUploadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في رفع الملف'**
  String get task_attachmentUploadError;

  /// No description provided for @task_attachmentMustUpload.
  ///
  /// In ar, this message translates to:
  /// **'يجب رفع المرفق أولاً'**
  String get task_attachmentMustUpload;

  /// No description provided for @task_attachmentView.
  ///
  /// In ar, this message translates to:
  /// **'عرض المرفق'**
  String get task_attachmentView;

  /// No description provided for @task_deadline.
  ///
  /// In ar, this message translates to:
  /// **'موعد التسليم'**
  String get task_deadline;

  /// No description provided for @task_deadlineAt.
  ///
  /// In ar, this message translates to:
  /// **'موعد التسليم:'**
  String get task_deadlineAt;

  /// No description provided for @task_deadlineExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get task_deadlineExpired;

  /// No description provided for @task_labels.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get task_labels;

  /// No description provided for @task_noLabels.
  ///
  /// In ar, this message translates to:
  /// **'بدون تصنيفات'**
  String get task_noLabels;

  /// No description provided for @task_selectLabels.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيفات'**
  String get task_selectLabels;

  /// No description provided for @task_assignees.
  ///
  /// In ar, this message translates to:
  /// **'المكلفين'**
  String get task_assignees;

  /// No description provided for @task_assigneeAll.
  ///
  /// In ar, this message translates to:
  /// **'جميع الموظفين'**
  String get task_assigneeAll;

  /// No description provided for @task_assigneeGroups.
  ///
  /// In ar, this message translates to:
  /// **'مجموعات محددة'**
  String get task_assigneeGroups;

  /// No description provided for @task_assigneeCustom.
  ///
  /// In ar, this message translates to:
  /// **'مستخدمين محددين'**
  String get task_assigneeCustom;

  /// No description provided for @task_assigneeSelect.
  ///
  /// In ar, this message translates to:
  /// **'اختر المكلفين'**
  String get task_assigneeSelect;

  /// No description provided for @task_assigneeSelectGroups.
  ///
  /// In ar, this message translates to:
  /// **'اختر المجموعات'**
  String get task_assigneeSelectGroups;

  /// No description provided for @task_noAssignees.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعيين مكلفين'**
  String get task_noAssignees;

  /// No description provided for @task_createdBy.
  ///
  /// In ar, this message translates to:
  /// **'أنشئت بواسطة'**
  String get task_createdBy;

  /// No description provided for @task_createdAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get task_createdAt;

  /// No description provided for @task_type.
  ///
  /// In ar, this message translates to:
  /// **'نوع المهمة'**
  String get task_type;

  /// No description provided for @task_typeOnce.
  ///
  /// In ar, this message translates to:
  /// **'لمرة واحدة'**
  String get task_typeOnce;

  /// No description provided for @task_typeRecurring.
  ///
  /// In ar, this message translates to:
  /// **'متكررة'**
  String get task_typeRecurring;

  /// No description provided for @task_info.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المهمة'**
  String get task_info;

  /// No description provided for @task_assigneeInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التكليف'**
  String get task_assigneeInfo;

  /// No description provided for @task_progressInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الإنجاز'**
  String get task_progressInfo;

  /// No description provided for @task_selectAtLeastOneGroup.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار مجموعة واحدة على الأقل'**
  String get task_selectAtLeastOneGroup;

  /// No description provided for @task_assignTo.
  ///
  /// In ar, this message translates to:
  /// **'تعيين المهمة إلى'**
  String get task_assignTo;

  /// No description provided for @task_selectGroups.
  ///
  /// In ar, this message translates to:
  /// **'اختر المجموعات:'**
  String get task_selectGroups;

  /// No description provided for @task_allUsers.
  ///
  /// In ar, this message translates to:
  /// **'جميع المستخدمين'**
  String get task_allUsers;

  /// No description provided for @task_allUsersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تعيين المهمة لجميع الموظفين'**
  String get task_allUsersSubtitle;

  /// No description provided for @task_specificGroups.
  ///
  /// In ar, this message translates to:
  /// **'مجموعات محددة'**
  String get task_specificGroups;

  /// No description provided for @task_specificGroupsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر المجموعات التي ستتلقى المهمة'**
  String get task_specificGroupsSubtitle;

  /// No description provided for @task_archivedTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة مؤرشفة'**
  String get task_archivedTask;

  /// No description provided for @task_activeTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة نشطة'**
  String get task_activeTask;

  /// No description provided for @task_recurringPaused.
  ///
  /// In ar, this message translates to:
  /// **'المهمة المتكررة متوقفة مؤقتاً'**
  String get task_recurringPaused;

  /// No description provided for @task_noLabelsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات متاحة. يمكنك إنشاء تصنيفات من لوحة التحكم.'**
  String get task_noLabelsAvailable;

  /// No description provided for @task_noGroupsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجموعات متاحة. قم بإنشاء مجموعات من لوحة التحكم أولاً.'**
  String get task_noGroupsAvailable;

  /// No description provided for @assignment_title.
  ///
  /// In ar, this message translates to:
  /// **'التكليف'**
  String get assignment_title;

  /// No description provided for @assignment_details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التكليف'**
  String get assignment_details;

  /// No description provided for @assignment_complete.
  ///
  /// In ar, this message translates to:
  /// **'تسليم المهمة'**
  String get assignment_complete;

  /// No description provided for @assignment_completeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسليم هذه المهمة؟'**
  String get assignment_completeConfirm;

  /// No description provided for @assignment_submit.
  ///
  /// In ar, this message translates to:
  /// **'تسليم'**
  String get assignment_submit;

  /// No description provided for @assignment_submitted.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get assignment_submitted;

  /// No description provided for @assignment_submittedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم المهمة بنجاح'**
  String get assignment_submittedSuccess;

  /// No description provided for @assignment_apologize.
  ///
  /// In ar, this message translates to:
  /// **'الاعتذار عن المهمة'**
  String get assignment_apologize;

  /// No description provided for @assignment_apologizeMessage.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال سبب الاعتذار (اختياري):'**
  String get assignment_apologizeMessage;

  /// No description provided for @assignment_apologizeReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الاعتذار'**
  String get assignment_apologizeReason;

  /// No description provided for @assignment_apologizeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'اعتذار'**
  String get assignment_apologizeConfirm;

  /// No description provided for @assignment_apologized.
  ///
  /// In ar, this message translates to:
  /// **'تم الاعتذار'**
  String get assignment_apologized;

  /// No description provided for @assignment_apologizedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الاعتذار عن المهمة بنجاح'**
  String get assignment_apologizedSuccess;

  /// No description provided for @assignment_reactivate.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تفعيل'**
  String get assignment_reactivate;

  /// No description provided for @assignment_reactivateConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إعادة تفعيل هذا التكليف؟'**
  String get assignment_reactivateConfirm;

  /// No description provided for @assignment_reactivated.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة التفعيل'**
  String get assignment_reactivated;

  /// No description provided for @assignment_statusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get assignment_statusPending;

  /// No description provided for @assignment_statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get assignment_statusCompleted;

  /// No description provided for @assignment_statusApologized.
  ///
  /// In ar, this message translates to:
  /// **'معتذر'**
  String get assignment_statusApologized;

  /// No description provided for @assignment_statusOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get assignment_statusOverdue;

  /// No description provided for @assignment_noAssignments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تكليفات'**
  String get assignment_noAssignments;

  /// No description provided for @assignment_myAssignments.
  ///
  /// In ar, this message translates to:
  /// **'تكليفاتي'**
  String get assignment_myAssignments;

  /// No description provided for @assignment_completedAt.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم في'**
  String get assignment_completedAt;

  /// No description provided for @assignment_apologizedAt.
  ///
  /// In ar, this message translates to:
  /// **'تم الاعتذار في'**
  String get assignment_apologizedAt;

  /// No description provided for @assignment_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل التكليف'**
  String get assignment_loadError;

  /// No description provided for @assignment_hasAttachment.
  ///
  /// In ar, this message translates to:
  /// **'يوجد مرفق'**
  String get assignment_hasAttachment;

  /// No description provided for @assignment_viewAttachment.
  ///
  /// In ar, this message translates to:
  /// **'عرض المرفق المُسلّم'**
  String get assignment_viewAttachment;

  /// No description provided for @group_title.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get group_title;

  /// No description provided for @group_name.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجموعة'**
  String get group_name;

  /// No description provided for @group_nameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المجموعة'**
  String get group_nameHint;

  /// No description provided for @group_nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجموعة مطلوب'**
  String get group_nameRequired;

  /// No description provided for @group_create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مجموعة'**
  String get group_create;

  /// No description provided for @group_createNew.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة جديدة'**
  String get group_createNew;

  /// No description provided for @group_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المجموعة'**
  String get group_edit;

  /// No description provided for @group_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجموعة'**
  String get group_delete;

  /// No description provided for @group_deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف المجموعة'**
  String get group_deleteConfirm;

  /// No description provided for @group_deleteMembers.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إزالة {count} عضو من هذه المجموعة'**
  String group_deleteMembers(int count);

  /// No description provided for @group_manage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المجموعات'**
  String get group_manage;

  /// No description provided for @group_manageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة مجموعات الموظفين'**
  String get group_manageSubtitle;

  /// No description provided for @group_manageMembers.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الأعضاء'**
  String get group_manageMembers;

  /// No description provided for @group_noGroups.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجموعات'**
  String get group_noGroups;

  /// No description provided for @group_noGroupsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بإنشاء مجموعات لتنظيم الموظفين'**
  String get group_noGroupsSubtitle;

  /// No description provided for @group_noMembers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أعضاء في هذه المجموعة'**
  String get group_noMembers;

  /// No description provided for @group_addMembers.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أعضاء'**
  String get group_addMembers;

  /// No description provided for @group_showMembers.
  ///
  /// In ar, this message translates to:
  /// **'الأعضاء'**
  String get group_showMembers;

  /// No description provided for @group_showAvailable.
  ///
  /// In ar, this message translates to:
  /// **'المتاحين'**
  String get group_showAvailable;

  /// No description provided for @group_totalMembers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأعضاء'**
  String get group_totalMembers;

  /// No description provided for @group_createdSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المجموعة بنجاح'**
  String get group_createdSuccess;

  /// No description provided for @group_updatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المجموعة بنجاح'**
  String get group_updatedSuccess;

  /// No description provided for @group_deletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المجموعة بنجاح'**
  String get group_deletedSuccess;

  /// No description provided for @group_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل المجموعات'**
  String get group_loadError;

  /// No description provided for @group_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن مجموعات...'**
  String get group_searchHint;

  /// No description provided for @group_noGroupsMatchingSearch.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على مجموعة تطابق \"{query}\"'**
  String group_noGroupsMatchingSearch(String query);

  /// No description provided for @group_membersOf.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء {name}'**
  String group_membersOf(String name);

  /// No description provided for @group_searchUsers.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن مستخدمين...'**
  String get group_searchUsers;

  /// No description provided for @group_noUsersAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمين متاحين'**
  String get group_noUsersAvailable;

  /// No description provided for @group_removeFromGroup.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المجموعة'**
  String get group_removeFromGroup;

  /// No description provided for @group_addToGroup.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للمجموعة'**
  String get group_addToGroup;

  /// No description provided for @group_nameTooShort.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجموعة قصير جداً'**
  String get group_nameTooShort;

  /// No description provided for @group_preview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة'**
  String get group_preview;

  /// No description provided for @label_title.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات'**
  String get label_title;

  /// No description provided for @label_name.
  ///
  /// In ar, this message translates to:
  /// **'اسم التصنيف'**
  String get label_name;

  /// No description provided for @label_nameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم التصنيف'**
  String get label_nameHint;

  /// No description provided for @label_nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم التصنيف مطلوب'**
  String get label_nameRequired;

  /// No description provided for @label_color.
  ///
  /// In ar, this message translates to:
  /// **'لون التصنيف'**
  String get label_color;

  /// No description provided for @label_create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء تصنيف'**
  String get label_create;

  /// No description provided for @label_createNew.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف جديد'**
  String get label_createNew;

  /// No description provided for @label_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التصنيف'**
  String get label_edit;

  /// No description provided for @label_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف التصنيف'**
  String get label_delete;

  /// No description provided for @label_manage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التصنيفات'**
  String get label_manage;

  /// No description provided for @label_manageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء تصنيفات لتنظيم المهام'**
  String get label_manageSubtitle;

  /// No description provided for @label_noLabels.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات'**
  String get label_noLabels;

  /// No description provided for @label_noLabelsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بإنشاء تصنيفات لتنظيم المهام'**
  String get label_noLabelsSubtitle;

  /// No description provided for @label_deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف التصنيف'**
  String get label_deleteConfirm;

  /// No description provided for @label_createdSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء التصنيف بنجاح'**
  String get label_createdSuccess;

  /// No description provided for @label_updatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث التصنيف بنجاح'**
  String get label_updatedSuccess;

  /// No description provided for @label_deletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف التصنيف بنجاح'**
  String get label_deletedSuccess;

  /// No description provided for @label_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل التصنيفات'**
  String get label_loadError;

  /// No description provided for @label_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن تصنيفات...'**
  String get label_searchHint;

  /// No description provided for @label_noLabelsMatchingSearch.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على تصنيف يطابق \"{query}\"'**
  String label_noLabelsMatchingSearch(String query);

  /// No description provided for @label_nameTooShort.
  ///
  /// In ar, this message translates to:
  /// **'اسم التصنيف قصير جداً'**
  String get label_nameTooShort;

  /// No description provided for @label_saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get label_saveChanges;

  /// No description provided for @label_createLabel.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء تصنيف'**
  String get label_createLabel;

  /// No description provided for @label_deleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف التصنيف \"{name}\"؟'**
  String label_deleteConfirmMessage(String name);

  /// No description provided for @label_disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get label_disabled;

  /// No description provided for @label_deactivate.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل'**
  String get label_deactivate;

  /// No description provided for @label_activate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get label_activate;

  /// No description provided for @label_preview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة'**
  String get label_preview;

  /// No description provided for @whitelist_title.
  ///
  /// In ar, this message translates to:
  /// **'القائمة البيضاء'**
  String get whitelist_title;

  /// No description provided for @whitelist_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة البريد الإلكتروني المعتمد'**
  String get whitelist_subtitle;

  /// No description provided for @whitelist_description.
  ///
  /// In ar, this message translates to:
  /// **'أضف عناوين البريد الإلكتروني المعتمدة للتسجيل المباشر'**
  String get whitelist_description;

  /// No description provided for @whitelist_addEmail.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى القائمة البيضاء'**
  String get whitelist_addEmail;

  /// No description provided for @whitelist_emailHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد الإلكتروني'**
  String get whitelist_emailHint;

  /// No description provided for @whitelist_emailCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ البريد الإلكتروني'**
  String get whitelist_emailCopied;

  /// No description provided for @whitelist_deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف'**
  String get whitelist_deleteConfirm;

  /// No description provided for @whitelist_deleteConfirmText.
  ///
  /// In ar, this message translates to:
  /// **'من القائمة البيضاء؟'**
  String get whitelist_deleteConfirmText;

  /// No description provided for @whitelist_noEmails.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناوين بريد إلكتروني'**
  String get whitelist_noEmails;

  /// No description provided for @whitelist_addedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى القائمة البيضاء بنجاح'**
  String get whitelist_addedSuccess;

  /// No description provided for @whitelist_deletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف من القائمة البيضاء بنجاح'**
  String get whitelist_deletedSuccess;

  /// No description provided for @whitelist_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل القائمة البيضاء'**
  String get whitelist_loadError;

  /// No description provided for @whitelist_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث بالبريد الإلكتروني...'**
  String get whitelist_searchHint;

  /// No description provided for @whitelist_noEntries.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناوين بريد إلكتروني'**
  String get whitelist_noEntries;

  /// No description provided for @whitelist_noEntriesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف عناوين بريد إلكتروني للسماح بالتسجيل المباشر'**
  String get whitelist_noEntriesSubtitle;

  /// No description provided for @whitelist_noEntriesMatchingSearch.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على بريد إلكتروني يطابق \"{query}\"'**
  String whitelist_noEntriesMatchingSearch(String query);

  /// No description provided for @whitelist_emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get whitelist_emailLabel;

  /// No description provided for @whitelist_emailRequired.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get whitelist_emailRequired;

  /// No description provided for @whitelist_emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get whitelist_emailInvalid;

  /// No description provided for @whitelist_role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get whitelist_role;

  /// No description provided for @whitelist_roleAdminDesc.
  ///
  /// In ar, this message translates to:
  /// **'وصول كامل لإدارة النظام'**
  String get whitelist_roleAdminDesc;

  /// No description provided for @whitelist_roleManagerDesc.
  ///
  /// In ar, this message translates to:
  /// **'يمكنه إنشاء المهام وإدارة الفريق'**
  String get whitelist_roleManagerDesc;

  /// No description provided for @whitelist_roleEmployeeDesc.
  ///
  /// In ar, this message translates to:
  /// **'يمكنه تنفيذ المهام الموكلة إليه'**
  String get whitelist_roleEmployeeDesc;

  /// No description provided for @whitelist_addTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى القائمة البيضاء'**
  String get whitelist_addTitle;

  /// No description provided for @whitelist_deleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إزالة \"{email}\" من القائمة البيضاء؟'**
  String whitelist_deleteConfirmMessage(String email);

  /// No description provided for @invitation_title.
  ///
  /// In ar, this message translates to:
  /// **'أكواد الدعوة'**
  String get invitation_title;

  /// No description provided for @invitation_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء وإدارة أكواد الدعوة'**
  String get invitation_subtitle;

  /// No description provided for @invitation_create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء كود دعوة'**
  String get invitation_create;

  /// No description provided for @invitation_createDescription.
  ///
  /// In ar, this message translates to:
  /// **'قم بإنشاء أكواد دعوة للمستخدمين الجدد'**
  String get invitation_createDescription;

  /// No description provided for @invitation_statusUsed.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get invitation_statusUsed;

  /// No description provided for @invitation_statusAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get invitation_statusAvailable;

  /// No description provided for @invitation_copyCode.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الكود'**
  String get invitation_copyCode;

  /// No description provided for @invitation_codeCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الكود'**
  String get invitation_codeCopied;

  /// No description provided for @invitation_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الكود'**
  String get invitation_delete;

  /// No description provided for @invitation_deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف كود الدعوة'**
  String get invitation_deleteConfirm;

  /// No description provided for @invitation_noCodes.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أكواد'**
  String get invitation_noCodes;

  /// No description provided for @invitation_noCodesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم إنشاء أي أكواد دعوة بعد'**
  String get invitation_noCodesSubtitle;

  /// No description provided for @invitation_noCodesAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أكواد متاحة'**
  String get invitation_noCodesAvailable;

  /// No description provided for @invitation_noCodesUsed.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أكواد مستخدمة'**
  String get invitation_noCodesUsed;

  /// No description provided for @invitation_usedBy.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم بواسطة'**
  String get invitation_usedBy;

  /// No description provided for @invitation_createdSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء كود الدعوة بنجاح'**
  String get invitation_createdSuccess;

  /// No description provided for @invitation_deletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف كود الدعوة بنجاح'**
  String get invitation_deletedSuccess;

  /// No description provided for @invitation_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل أكواد الدعوة'**
  String get invitation_loadError;

  /// No description provided for @invitation_tabAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاحة'**
  String get invitation_tabAvailable;

  /// No description provided for @invitation_tabUsed.
  ///
  /// In ar, this message translates to:
  /// **'مستخدمة'**
  String get invitation_tabUsed;

  /// No description provided for @invitation_role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get invitation_role;

  /// No description provided for @invitation_createCodeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنشاء كود فريد لدعوة مستخدم جديد'**
  String get invitation_createCodeSubtitle;

  /// No description provided for @invitation_createCode.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الكود'**
  String get invitation_createCode;

  /// No description provided for @invitation_successTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الكود بنجاح'**
  String get invitation_successTitle;

  /// No description provided for @invitation_invitationCode.
  ///
  /// In ar, this message translates to:
  /// **'كود الدعوة'**
  String get invitation_invitationCode;

  /// No description provided for @invitation_roleLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدور: {role}'**
  String invitation_roleLabel(String role);

  /// No description provided for @invitation_copyCodeButton.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الكود'**
  String get invitation_copyCodeButton;

  /// No description provided for @invitation_usedOn.
  ///
  /// In ar, this message translates to:
  /// **'استخدم في {date}'**
  String invitation_usedOn(String date);

  /// No description provided for @invitation_noCodesAvailableSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تم استخدام جميع الأكواد، قم بإنشاء أكواد جديدة'**
  String get invitation_noCodesAvailableSubtitle;

  /// No description provided for @invitation_noCodesUsedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم استخدام أي كود دعوة بعد'**
  String get invitation_noCodesUsedSubtitle;

  /// No description provided for @invitation_deleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف كود الدعوة \"{code}\"؟'**
  String invitation_deleteConfirmMessage(String code);

  /// No description provided for @user_title.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين'**
  String get user_title;

  /// No description provided for @user_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة حسابات المستخدمين والأدوار'**
  String get user_subtitle;

  /// No description provided for @user_manage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get user_manage;

  /// No description provided for @user_manageActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات المسؤول'**
  String get user_manageActions;

  /// No description provided for @user_welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً،'**
  String get user_welcome;

  /// No description provided for @user_welcomeName.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String user_welcomeName(String name);

  /// No description provided for @user_noUsers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمين'**
  String get user_noUsers;

  /// No description provided for @user_noUsersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي مستخدمين بعد'**
  String get user_noUsersSubtitle;

  /// No description provided for @user_noUsersAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمين متاحين'**
  String get user_noUsersAvailable;

  /// No description provided for @user_noUsersInRole.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمين بدور {role}'**
  String user_noUsersInRole(String role);

  /// No description provided for @user_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل المستخدمين'**
  String get user_loadError;

  /// No description provided for @user_details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المستخدم'**
  String get user_details;

  /// No description provided for @user_profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get user_profile;

  /// No description provided for @user_unknown.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم غير معروف'**
  String get user_unknown;

  /// No description provided for @user_roleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get user_roleAdmin;

  /// No description provided for @user_roleSupervisor.
  ///
  /// In ar, this message translates to:
  /// **'مشرف'**
  String get user_roleSupervisor;

  /// No description provided for @user_roleManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get user_roleManager;

  /// No description provided for @user_roleEmployee.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get user_roleEmployee;

  /// No description provided for @user_roleAdmins.
  ///
  /// In ar, this message translates to:
  /// **'مدراء النظام'**
  String get user_roleAdmins;

  /// No description provided for @user_roleSupervisors.
  ///
  /// In ar, this message translates to:
  /// **'المشرفين'**
  String get user_roleSupervisors;

  /// No description provided for @user_roleManagers.
  ///
  /// In ar, this message translates to:
  /// **'المدراء'**
  String get user_roleManagers;

  /// No description provided for @user_roleEmployees.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get user_roleEmployees;

  /// No description provided for @user_changeRole.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الدور'**
  String get user_changeRole;

  /// No description provided for @user_changeRoleConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تغيير دور {user} إلى {role}؟'**
  String user_changeRoleConfirm(String user, String role);

  /// No description provided for @user_roleChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير الدور بنجاح'**
  String get user_roleChanged;

  /// No description provided for @user_roleChangeError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تغيير الدور'**
  String get user_roleChangeError;

  /// No description provided for @user_cannotChangeAdmin.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير دور مدير النظام'**
  String get user_cannotChangeAdmin;

  /// No description provided for @user_manageGroups.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المجموعات'**
  String get user_manageGroups;

  /// No description provided for @user_managedGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات المُدارة'**
  String get user_managedGroups;

  /// No description provided for @user_managedGroupsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مجموعة'**
  String user_managedGroupsCount(int count);

  /// No description provided for @user_noManagedGroups.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعيين مجموعات بعد'**
  String get user_noManagedGroups;

  /// No description provided for @user_canAssignAll.
  ///
  /// In ar, this message translates to:
  /// **'يمكنه التعيين لجميع الموظفين'**
  String get user_canAssignAll;

  /// No description provided for @user_allowAssignAll.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالتعيين لجميع الموظفين'**
  String get user_allowAssignAll;

  /// No description provided for @notification_title.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notification_title;

  /// No description provided for @notification_noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get notification_noNotifications;

  /// No description provided for @notification_noNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الإشعارات الجديدة هنا'**
  String get notification_noNotificationsSubtitle;

  /// No description provided for @notification_markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get notification_markAllRead;

  /// No description provided for @notification_markRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كمقروء'**
  String get notification_markRead;

  /// No description provided for @notification_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get notification_delete;

  /// No description provided for @notification_deleteAll.
  ///
  /// In ar, this message translates to:
  /// **'حذف الكل'**
  String get notification_deleteAll;

  /// No description provided for @notification_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل الإشعارات'**
  String get notification_loadError;

  /// No description provided for @notification_deleteError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في حذف الإشعار'**
  String get notification_deleteError;

  /// No description provided for @archive_title.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف'**
  String get archive_title;

  /// No description provided for @archive_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'المهام المؤرشفة'**
  String get archive_subtitle;

  /// No description provided for @archive_noArchived.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام مؤرشفة'**
  String get archive_noArchived;

  /// No description provided for @archive_noArchivedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر المهام المؤرشفة هنا'**
  String get archive_noArchivedSubtitle;

  /// No description provided for @archive_restore.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get archive_restore;

  /// No description provided for @archive_restoreConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد استعادة هذه المهمة؟'**
  String get archive_restoreConfirm;

  /// No description provided for @archive_restoredSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة المهمة بنجاح'**
  String get archive_restoredSuccess;

  /// No description provided for @archive_empty.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف فارغ'**
  String get archive_empty;

  /// No description provided for @archive_publishTask.
  ///
  /// In ar, this message translates to:
  /// **'نشر المهمة'**
  String get archive_publishTask;

  /// No description provided for @archive_publishForToday.
  ///
  /// In ar, this message translates to:
  /// **'نشر لليوم فقط'**
  String get archive_publishForToday;

  /// No description provided for @archive_publishForTodaySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيتم نشر المهمة للموظفين لليوم فقط'**
  String get archive_publishForTodaySubtitle;

  /// No description provided for @archive_deadlineExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الموعد النهائي لمهام اليوم ({time})'**
  String archive_deadlineExpired(String time);

  /// No description provided for @archive_publishAsRecurring.
  ///
  /// In ar, this message translates to:
  /// **'نشر كمهمة متكررة'**
  String get archive_publishAsRecurring;

  /// No description provided for @archive_publishAsRecurringSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيتم نشر المهمة يومياً للموظفين'**
  String get archive_publishAsRecurringSubtitle;

  /// No description provided for @archive_wasRecurring.
  ///
  /// In ar, this message translates to:
  /// **'كانت متكررة'**
  String get archive_wasRecurring;

  /// No description provided for @archive_wasOneTime.
  ///
  /// In ar, this message translates to:
  /// **'كانت لمرة واحدة'**
  String get archive_wasOneTime;

  /// No description provided for @archive_timeExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت'**
  String get archive_timeExpired;

  /// No description provided for @archive_publishConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشر لليوم فقط'**
  String get archive_publishConfirmTitle;

  /// No description provided for @archive_publishConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم نشر هذه المهمة للموظفين لليوم فقط ولن تتكرر.'**
  String get archive_publishConfirmMessage;

  /// No description provided for @archive_publishRecurringConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشر كمهمة متكررة'**
  String get archive_publishRecurringConfirmTitle;

  /// No description provided for @archive_publishRecurringConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم نشر هذه المهمة يومياً للموظفين. يمكنك إيقافها لاحقاً من تفاصيل المهمة.'**
  String get archive_publishRecurringConfirmMessage;

  /// No description provided for @common_publish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get common_publish;

  /// No description provided for @settings_title.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings_title;

  /// No description provided for @settings_general.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات العامة'**
  String get settings_general;

  /// No description provided for @settings_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت المهام المتكررة والمواعيد النهائية'**
  String get settings_subtitle;

  /// No description provided for @settings_recurringTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت المهام المتكررة'**
  String get settings_recurringTime;

  /// No description provided for @settings_recurringTimeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الوقت الذي يتم فيه جدولة المهام المتكررة يومياً'**
  String get settings_recurringTimeSubtitle;

  /// No description provided for @settings_recurringTimeSelect.
  ///
  /// In ar, this message translates to:
  /// **'اختر وقت المهام المتكررة'**
  String get settings_recurringTimeSelect;

  /// No description provided for @settings_deadlineTime.
  ///
  /// In ar, this message translates to:
  /// **'الموعد النهائي للمهام'**
  String get settings_deadlineTime;

  /// No description provided for @settings_deadlineTimeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الوقت الذي تنتهي فيه المهام يومياً'**
  String get settings_deadlineTimeSubtitle;

  /// No description provided for @settings_deadlineTimeSelect.
  ///
  /// In ar, this message translates to:
  /// **'اختر الموعد النهائي للمهام'**
  String get settings_deadlineTimeSelect;

  /// No description provided for @settings_dailyWindow.
  ///
  /// In ar, this message translates to:
  /// **'نافذة المهام اليومية'**
  String get settings_dailyWindow;

  /// No description provided for @settings_loadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل الإعدادات'**
  String get settings_loadError;

  /// No description provided for @settings_saveError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في حفظ الإعدادات'**
  String get settings_saveError;

  /// No description provided for @settings_savedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات بنجاح'**
  String get settings_savedSuccess;

  /// No description provided for @settings_confirmChange.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التغيير'**
  String get settings_confirmChange;

  /// No description provided for @settings_changeRecurringTime.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تغيير وقت المهام المتكررة إلى {time}؟'**
  String settings_changeRecurringTime(String time);

  /// No description provided for @settings_changeDeadlineTime.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تغيير الموعد النهائي للمهام إلى {time}؟'**
  String settings_changeDeadlineTime(String time);

  /// No description provided for @controlPanel_title.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get controlPanel_title;

  /// No description provided for @controlPanel_userManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get controlPanel_userManagement;

  /// No description provided for @controlPanel_taskManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المهام'**
  String get controlPanel_taskManagement;

  /// No description provided for @controlPanel_registration.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل والدعوات'**
  String get controlPanel_registration;

  /// No description provided for @controlPanel_settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get controlPanel_settings;

  /// No description provided for @admin_home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get admin_home;

  /// No description provided for @admin_statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get admin_statistics;

  /// No description provided for @admin_tasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get admin_tasks;

  /// No description provided for @statistics_title.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics_title;

  /// No description provided for @statistics_loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الإحصائيات...'**
  String get statistics_loading;

  /// No description provided for @statistics_overview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على المهام'**
  String get statistics_overview;

  /// No description provided for @statistics_totalTasks.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المهام'**
  String get statistics_totalTasks;

  /// No description provided for @statistics_completed.
  ///
  /// In ar, this message translates to:
  /// **'المكتملة'**
  String get statistics_completed;

  /// No description provided for @statistics_inProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get statistics_inProgress;

  /// No description provided for @statistics_apologized.
  ///
  /// In ar, this message translates to:
  /// **'معتذر عنها'**
  String get statistics_apologized;

  /// No description provided for @statistics_thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get statistics_thisWeek;

  /// No description provided for @statistics_thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get statistics_thisMonth;

  /// No description provided for @statistics_bestEmployees.
  ///
  /// In ar, this message translates to:
  /// **'أفضل الموظفين'**
  String get statistics_bestEmployees;

  /// No description provided for @statistics_completionRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل الإنجاز'**
  String get statistics_completionRate;

  /// No description provided for @statistics_apologyRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل الاعتذار'**
  String get statistics_apologyRate;

  /// No description provided for @statistics_noData.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي بيانات في هذه الفترة'**
  String get statistics_noData;

  /// No description provided for @statistics_noUsers.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي مستخدمين في هذه الفترة'**
  String get statistics_noUsers;

  /// No description provided for @statistics_noTasks.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تسجيل أي مهام في هذه الفترة'**
  String get statistics_noTasks;

  /// No description provided for @statistics_total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get statistics_total;

  /// No description provided for @statistics_supervisors.
  ///
  /// In ar, this message translates to:
  /// **'مشرفين'**
  String get statistics_supervisors;

  /// No description provided for @statistics_managers.
  ///
  /// In ar, this message translates to:
  /// **'مدراء'**
  String get statistics_managers;

  /// No description provided for @statistics_employees.
  ///
  /// In ar, this message translates to:
  /// **'موظفين'**
  String get statistics_employees;

  /// No description provided for @statistics_performanceRates.
  ///
  /// In ar, this message translates to:
  /// **'معدلات الأداء'**
  String get statistics_performanceRates;

  /// No description provided for @statistics_taskStatistics.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات المهام'**
  String get statistics_taskStatistics;

  /// No description provided for @statistics_tasks.
  ///
  /// In ar, this message translates to:
  /// **'مهمة'**
  String get statistics_tasks;

  /// No description provided for @notes_title.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get notes_title;

  /// No description provided for @notes_noNotes.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات بعد'**
  String get notes_noNotes;

  /// No description provided for @notes_addButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة'**
  String get notes_addButton;

  /// No description provided for @notes_newNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة جديدة'**
  String get notes_newNote;

  /// No description provided for @notes_noteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظتك هنا...'**
  String get notes_noteHint;

  /// No description provided for @notes_count.
  ///
  /// In ar, this message translates to:
  /// **'{count} ملاحظة'**
  String notes_count(int count);

  /// No description provided for @notes_addedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الملاحظة بنجاح'**
  String get notes_addedSuccess;

  /// No description provided for @notes_deletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الملاحظة بنجاح'**
  String get notes_deletedSuccess;

  /// No description provided for @error_generic.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get error_generic;

  /// No description provided for @error_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get error_retry;

  /// No description provided for @error_permissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك صلاحية للوصول إلى هذه البيانات.'**
  String get error_permissionDenied;

  /// No description provided for @error_userNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على بيانات المستخدم'**
  String get error_userNotFound;

  /// No description provided for @error_taskNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المهمة'**
  String get error_taskNotFound;

  /// No description provided for @error_assignmentNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على التكليف'**
  String get error_assignmentNotFound;

  /// No description provided for @error_noInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.'**
  String get error_noInternet;

  /// No description provided for @error_fileOpen.
  ///
  /// In ar, this message translates to:
  /// **'لم يتمكن من فتح الملف'**
  String get error_fileOpen;

  /// No description provided for @error_uploadFile.
  ///
  /// In ar, this message translates to:
  /// **'فشل في رفع الملف'**
  String get error_uploadFile;

  /// No description provided for @error_loadData.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل البيانات'**
  String get error_loadData;

  /// No description provided for @error_saveData.
  ///
  /// In ar, this message translates to:
  /// **'فشل في حفظ البيانات'**
  String get error_saveData;

  /// No description provided for @error_unknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير معروف'**
  String get error_unknown;

  /// No description provided for @date_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get date_today;

  /// No description provided for @date_yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get date_yesterday;

  /// No description provided for @date_tomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً'**
  String get date_tomorrow;

  /// No description provided for @date_thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get date_thisWeek;

  /// No description provided for @date_thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get date_thisMonth;

  /// No description provided for @date_lastWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع الماضي'**
  String get date_lastWeek;

  /// No description provided for @date_lastMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الماضي'**
  String get date_lastMonth;

  /// No description provided for @time_am.
  ///
  /// In ar, this message translates to:
  /// **'صباحاً'**
  String get time_am;

  /// No description provided for @time_pm.
  ///
  /// In ar, this message translates to:
  /// **'مساءً'**
  String get time_pm;

  /// No description provided for @time_ago.
  ///
  /// In ar, this message translates to:
  /// **'منذ'**
  String get time_ago;

  /// No description provided for @time_remaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقي'**
  String get time_remaining;

  /// No description provided for @color_red.
  ///
  /// In ar, this message translates to:
  /// **'أحمر'**
  String get color_red;

  /// No description provided for @color_blue.
  ///
  /// In ar, this message translates to:
  /// **'أزرق'**
  String get color_blue;

  /// No description provided for @color_green.
  ///
  /// In ar, this message translates to:
  /// **'أخضر'**
  String get color_green;

  /// No description provided for @color_yellow.
  ///
  /// In ar, this message translates to:
  /// **'أصفر'**
  String get color_yellow;

  /// No description provided for @color_purple.
  ///
  /// In ar, this message translates to:
  /// **'أرجواني'**
  String get color_purple;

  /// No description provided for @color_pink.
  ///
  /// In ar, this message translates to:
  /// **'وردي'**
  String get color_pink;

  /// No description provided for @color_cyan.
  ///
  /// In ar, this message translates to:
  /// **'سماوي'**
  String get color_cyan;

  /// No description provided for @color_amber.
  ///
  /// In ar, this message translates to:
  /// **'كهرماني'**
  String get color_amber;

  /// No description provided for @color_lime.
  ///
  /// In ar, this message translates to:
  /// **'ليموني'**
  String get color_lime;

  /// No description provided for @color_indigo.
  ///
  /// In ar, this message translates to:
  /// **'نيلي'**
  String get color_indigo;

  /// No description provided for @color_teal.
  ///
  /// In ar, this message translates to:
  /// **'فيروزي'**
  String get color_teal;

  /// No description provided for @color_orange.
  ///
  /// In ar, this message translates to:
  /// **'برتقالي'**
  String get color_orange;

  /// No description provided for @color_emerald.
  ///
  /// In ar, this message translates to:
  /// **'زمردي'**
  String get color_emerald;

  /// No description provided for @color_sky.
  ///
  /// In ar, this message translates to:
  /// **'سماوي فاتح'**
  String get color_sky;

  /// No description provided for @color_violet.
  ///
  /// In ar, this message translates to:
  /// **'بنفسجي'**
  String get color_violet;

  /// No description provided for @color_fuchsia.
  ///
  /// In ar, this message translates to:
  /// **'فوشي'**
  String get color_fuchsia;

  /// No description provided for @color_rose.
  ///
  /// In ar, this message translates to:
  /// **'وردي فاتح'**
  String get color_rose;

  /// No description provided for @color_stone.
  ///
  /// In ar, this message translates to:
  /// **'رمادي حجري'**
  String get color_stone;

  /// No description provided for @common_pickFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختر من المعرض'**
  String get common_pickFromGallery;

  /// No description provided for @common_takePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقط صورة'**
  String get common_takePhoto;

  /// No description provided for @common_selectFile.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملف'**
  String get common_selectFile;

  /// No description provided for @common_uploading.
  ///
  /// In ar, this message translates to:
  /// **'جاري الرفع...'**
  String get common_uploading;

  /// No description provided for @common_of.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get common_of;

  /// No description provided for @common_unknown.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get common_unknown;

  /// No description provided for @task_loading_message.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المهمة...'**
  String get task_loading_message;

  /// No description provided for @task_noAssignments.
  ///
  /// In ar, this message translates to:
  /// **'لا تكليفات'**
  String get task_noAssignments;

  /// No description provided for @task_tasksCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مهمة مكتملة'**
  String get task_tasksCompleted;

  /// No description provided for @task_assigneesCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكلف أنهوا المهمة'**
  String get task_assigneesCompleted;

  /// No description provided for @task_assigneesToday.
  ///
  /// In ar, this message translates to:
  /// **'المكلفين اليوم'**
  String get task_assigneesToday;

  /// No description provided for @task_noAssigneesToday.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مكلفين'**
  String get task_noAssigneesToday;

  /// No description provided for @task_noAssigneesTodaySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تكليف أي شخص بهذه المهمة اليوم'**
  String get task_noAssigneesTodaySubtitle;

  /// No description provided for @task_stop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get task_stop;

  /// No description provided for @task_attachment.
  ///
  /// In ar, this message translates to:
  /// **'المرفق'**
  String get task_attachment;

  /// No description provided for @task_hasAttachment.
  ///
  /// In ar, this message translates to:
  /// **'يوجد مرفق'**
  String get task_hasAttachment;

  /// No description provided for @task_noTasksAssignedToday.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعيين أي مهام لك اليوم'**
  String get task_noTasksAssignedToday;

  /// No description provided for @assignment_loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المهمة...'**
  String get assignment_loading;

  /// No description provided for @assignment_attachmentRequiredMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذه المهمة تتطلب إرفاق ملف'**
  String get assignment_attachmentRequiredMessage;

  /// No description provided for @assignment_attachmentRequiredHint.
  ///
  /// In ar, this message translates to:
  /// **'يرجى رفع صورة أو ملف قبل تسليم المهمة'**
  String get assignment_attachmentRequiredHint;

  /// No description provided for @assignment_submitConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسليم'**
  String get assignment_submitConfirmTitle;

  /// No description provided for @assignment_apologizeReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'سبب الاعتذار...'**
  String get assignment_apologizeReasonHint;

  /// No description provided for @assignment_completionInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الإكمال'**
  String get assignment_completionInfo;

  /// No description provided for @assignment_completedByAdmin.
  ///
  /// In ar, this message translates to:
  /// **'(تم التسليم بواسطة الإدارة)'**
  String get assignment_completedByAdmin;

  /// No description provided for @assignment_byAdmin.
  ///
  /// In ar, this message translates to:
  /// **'(بواسطة الإدارة)'**
  String get assignment_byAdmin;

  /// No description provided for @assignment_overdueLocked.
  ///
  /// In ar, this message translates to:
  /// **'متأخر - مغلق'**
  String get assignment_overdueLocked;

  /// No description provided for @assignment_uploadFileFirst.
  ///
  /// In ar, this message translates to:
  /// **'ارفع الملف أولاً'**
  String get assignment_uploadFileFirst;

  /// No description provided for @assignment_fileUploadedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع الملف بنجاح'**
  String get assignment_fileUploadedSuccess;

  /// No description provided for @assignment_fileUploadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في رفع الملف. حاول مرة أخرى.'**
  String get assignment_fileUploadError;

  /// No description provided for @error_filePick.
  ///
  /// In ar, this message translates to:
  /// **'فشل في اختيار الملف'**
  String get error_filePick;

  /// No description provided for @error_fileOpenError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في فتح الملف'**
  String get error_fileOpenError;

  /// No description provided for @error_fileOpenGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء فتح الملف'**
  String get error_fileOpenGeneric;

  /// No description provided for @error_loadTask.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحميل المهمة'**
  String get error_loadTask;

  /// No description provided for @assignment_submitTask.
  ///
  /// In ar, this message translates to:
  /// **'تسليم المهمة'**
  String get assignment_submitTask;

  /// No description provided for @assignment_submitConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسليم هذه المهمة؟'**
  String get assignment_submitConfirmMessage;

  /// No description provided for @assignment_mustUploadFirst.
  ///
  /// In ar, this message translates to:
  /// **'يجب رفع المرفق أولاً'**
  String get assignment_mustUploadFirst;

  /// No description provided for @assignment_attachmentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع المرفق'**
  String get assignment_attachmentUploaded;

  /// No description provided for @common_change.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get common_change;

  /// No description provided for @settings_recurringTimeBeforeDeadline.
  ///
  /// In ar, this message translates to:
  /// **'وقت المهام المتكررة يجب أن يكون قبل الموعد النهائي'**
  String get settings_recurringTimeBeforeDeadline;

  /// No description provided for @settings_deadlineAfterRecurringTime.
  ///
  /// In ar, this message translates to:
  /// **'الموعد النهائي يجب أن يكون بعد وقت المهام المتكررة'**
  String get settings_deadlineAfterRecurringTime;

  /// No description provided for @settings_fromTo.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to}'**
  String settings_fromTo(String from, String to);

  /// No description provided for @settings_saving.
  ///
  /// In ar, this message translates to:
  /// **'جاري حفظ الإعدادات...'**
  String get settings_saving;

  /// No description provided for @settings_appTheme.
  ///
  /// In ar, this message translates to:
  /// **'مظهر التطبيق'**
  String get settings_appTheme;

  /// No description provided for @settings_chooseTheme.
  ///
  /// In ar, this message translates to:
  /// **'اختر المظهر المفضل لديك'**
  String get settings_chooseTheme;

  /// No description provided for @user_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث بالاسم أو البريد الإلكتروني...'**
  String get user_searchHint;

  /// No description provided for @user_noUsersMatchingSearch.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على مستخدم يطابق \"{query}\"'**
  String user_noUsersMatchingSearch(String query);

  /// No description provided for @user_loadingProfile.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الملف الشخصي...'**
  String get user_loadingProfile;

  /// No description provided for @user_notFound.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم غير موجود'**
  String get user_notFound;

  /// No description provided for @user_notFoundMessage.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على بيانات المستخدم'**
  String get user_notFoundMessage;

  /// No description provided for @user_promoteToManager.
  ///
  /// In ar, this message translates to:
  /// **'ترقية إلى مشرف'**
  String get user_promoteToManager;

  /// No description provided for @user_demoteToEmployee.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إلى موظف'**
  String get user_demoteToEmployee;

  /// No description provided for @user_promoteDescription.
  ///
  /// In ar, this message translates to:
  /// **'سيتمكن المستخدم من إنشاء المهام وإدارة الفرق'**
  String get user_promoteDescription;

  /// No description provided for @user_demoteDescription.
  ///
  /// In ar, this message translates to:
  /// **'سيفقد المستخدم صلاحيات الإشراف'**
  String get user_demoteDescription;

  /// No description provided for @user_changeRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تغيير الدور'**
  String get user_changeRoleTitle;

  /// No description provided for @user_promoteWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إزالة المستخدم من مجموعته الحالية وسيتمكن من إنشاء المهام بعد تعيين مجموعات له.'**
  String get user_promoteWarning;

  /// No description provided for @user_demoteWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيفقد المستخدم صلاحيات الإشراف. المهام التي أنشأها ستبقى كما هي.'**
  String get user_demoteWarning;

  /// No description provided for @user_manageGroupsFor.
  ///
  /// In ar, this message translates to:
  /// **'إدارة مجموعات {name}'**
  String user_manageGroupsFor(String name);

  /// No description provided for @user_assignToAllEmployees.
  ///
  /// In ar, this message translates to:
  /// **'تعيين لجميع الموظفين'**
  String get user_assignToAllEmployees;

  /// No description provided for @user_assignToAllDescription.
  ///
  /// In ar, this message translates to:
  /// **'السماح للمشرف بتعيين المهام لجميع الموظفين'**
  String get user_assignToAllDescription;

  /// No description provided for @user_selectGroups.
  ///
  /// In ar, this message translates to:
  /// **'اختر المجموعات'**
  String get user_selectGroups;

  /// No description provided for @user_noGroupsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجموعات متاحة'**
  String get user_noGroupsAvailable;

  /// No description provided for @user_managesGroups.
  ///
  /// In ar, this message translates to:
  /// **'يدير {count} مجموعة'**
  String user_managesGroups(int count);

  /// No description provided for @task_todayAssignments.
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get task_todayAssignments;

  /// No description provided for @stats_statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get stats_statistics;

  /// No description provided for @stats_totalTasks.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المهام'**
  String get stats_totalTasks;

  /// No description provided for @stats_completed.
  ///
  /// In ar, this message translates to:
  /// **'المكتملة'**
  String get stats_completed;

  /// No description provided for @stats_apologized.
  ///
  /// In ar, this message translates to:
  /// **'معتذر عنها'**
  String get stats_apologized;

  /// No description provided for @stats_completionRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الإنجاز'**
  String get stats_completionRate;

  /// No description provided for @timeFilter_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get timeFilter_today;

  /// No description provided for @timeFilter_thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get timeFilter_thisWeek;

  /// No description provided for @timeFilter_thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get timeFilter_thisMonth;

  /// No description provided for @admin_adminActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات المسؤول'**
  String get admin_adminActions;

  /// No description provided for @manager_cannotCreateTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك إنشاء مهام'**
  String get manager_cannotCreateTasks;

  /// No description provided for @manager_noGroupsAssigned.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تعيين مجموعات لك بعد.\nيرجى التواصل مع مدير النظام لتعيين مجموعات يمكنك إدارتها.'**
  String get manager_noGroupsAssigned;

  /// No description provided for @manager_canCreateOnlyWithGroups.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إنشاء مهام فقط عندما يتم تعيين مجموعة واحدة على الأقل لك، أو عند منحك صلاحية التعيين لجميع الموظفين.'**
  String get manager_canCreateOnlyWithGroups;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
