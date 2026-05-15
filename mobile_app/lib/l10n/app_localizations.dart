import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In bn, this message translates to:
  /// **'এক্সপেন্স ট্র্যাকার'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ব্যক্তিগত অর্থ ব্যবস্থাপক'**
  String get appTagline;

  /// No description provided for @signIn.
  ///
  /// In bn, this message translates to:
  /// **'সাইন ইন'**
  String get signIn;

  /// No description provided for @signInToAccount.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অ্যাকাউন্টে সাইন ইন করুন'**
  String get signInToAccount;

  /// No description provided for @signUp.
  ///
  /// In bn, this message translates to:
  /// **'সাইন আপ'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট তৈরি করুন'**
  String get createAccount;

  /// No description provided for @startTracking.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অর্থ ট্র্যাক শুরু করুন'**
  String get startTracking;

  /// No description provided for @email.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল'**
  String get email;

  /// No description provided for @password.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড'**
  String get password;

  /// No description provided for @passwordMin.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড (কমপক্ষে ৮ অক্ষর)'**
  String get passwordMin;

  /// No description provided for @confirmPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড নিশ্চিত করুন'**
  String get confirmPassword;

  /// No description provided for @yourName.
  ///
  /// In bn, this message translates to:
  /// **'আপনার নাম (ঐচ্ছিক)'**
  String get yourName;

  /// No description provided for @phoneNumber.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর (ঐচ্ছিক)'**
  String get phoneNumber;

  /// No description provided for @noAccount.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট নেই? তৈরি করুন'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In bn, this message translates to:
  /// **'ইতিমধ্যে অ্যাকাউন্ট আছে? সাইন ইন করুন'**
  String get haveAccount;

  /// No description provided for @loginFailed.
  ///
  /// In bn, this message translates to:
  /// **'লগইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In bn, this message translates to:
  /// **'নিবন্ধন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।'**
  String get registerFailed;

  /// No description provided for @incorrectCredentials.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল বা পাসওয়ার্ড ভুল।'**
  String get incorrectCredentials;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In bn, this message translates to:
  /// **'এই ইমেইল ইতিমধ্যে নিবন্ধিত। সাইন ইন করুন।'**
  String get emailAlreadyRegistered;

  /// No description provided for @cannotReachServer.
  ///
  /// In bn, this message translates to:
  /// **'সার্ভারে সংযোগ করা যাচ্ছে না। আপনার সংযোগ পরীক্ষা করুন।'**
  String get cannotReachServer;

  /// No description provided for @serverError.
  ///
  /// In bn, this message translates to:
  /// **'সার্ভার সমস্যা। পরে আবার চেষ্টা করুন।'**
  String get serverError;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড মিলছে না।'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড কমপক্ষে ৮ অক্ষর হতে হবে।'**
  String get passwordTooShort;

  /// No description provided for @emailPasswordRequired.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল এবং পাসওয়ার্ড আবশ্যক।'**
  String get emailPasswordRequired;

  /// No description provided for @dashboard.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ড'**
  String get dashboard;

  /// No description provided for @ledger.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন'**
  String get ledger;

  /// No description provided for @insights.
  ///
  /// In bn, this message translates to:
  /// **'বিশ্লেষণ'**
  String get insights;

  /// No description provided for @reminders.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার'**
  String get reminders;

  /// No description provided for @settings.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get settings;

  /// No description provided for @hi.
  ///
  /// In bn, this message translates to:
  /// **'হ্যালো, {name} 👋'**
  String hi(String name);

  /// No description provided for @expenseTracker.
  ///
  /// In bn, this message translates to:
  /// **'এক্সপেন্স ট্র্যাকার'**
  String get expenseTracker;

  /// No description provided for @totalBalance.
  ///
  /// In bn, this message translates to:
  /// **'মোট ব্যালেন্স'**
  String get totalBalance;

  /// No description provided for @incomeThisMonth.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের আয়'**
  String get incomeThisMonth;

  /// No description provided for @expensesThisMonth.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের খরচ'**
  String get expensesThisMonth;

  /// No description provided for @netThisMonth.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের নেট'**
  String get netThisMonth;

  /// No description provided for @recentTransactions.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক লেনদেন'**
  String get recentTransactions;

  /// No description provided for @upcoming.
  ///
  /// In bn, this message translates to:
  /// **'আসন্ন'**
  String get upcoming;

  /// No description provided for @noTransactionsYet.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো লেনদেন নেই। প্রথমটি তৈরি করুন!'**
  String get noTransactionsYet;

  /// No description provided for @noUpcomingReminders.
  ///
  /// In bn, this message translates to:
  /// **'কোনো আসন্ন রিমাইন্ডার নেই'**
  String get noUpcomingReminders;

  /// No description provided for @whatShouldWeCallYou.
  ///
  /// In bn, this message translates to:
  /// **'আমরা আপনাকে কী নামে ডাকব?'**
  String get whatShouldWeCallYou;

  /// No description provided for @save.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ করুন'**
  String get save;

  /// No description provided for @pay.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধ'**
  String get pay;

  /// No description provided for @skip.
  ///
  /// In bn, this message translates to:
  /// **'এড়িয়ে যান'**
  String get skip;

  /// No description provided for @newTransaction.
  ///
  /// In bn, this message translates to:
  /// **'নতুন লেনদেন'**
  String get newTransaction;

  /// No description provided for @transactions.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন'**
  String get transactions;

  /// No description provided for @allMoneyMovements.
  ///
  /// In bn, this message translates to:
  /// **'সকল লেনদেন'**
  String get allMoneyMovements;

  /// No description provided for @add.
  ///
  /// In bn, this message translates to:
  /// **'যোগ করুন'**
  String get add;

  /// No description provided for @allTypes.
  ///
  /// In bn, this message translates to:
  /// **'সব ধরন'**
  String get allTypes;

  /// No description provided for @allBuckets.
  ///
  /// In bn, this message translates to:
  /// **'সব বাকেট'**
  String get allBuckets;

  /// No description provided for @allPeople.
  ///
  /// In bn, this message translates to:
  /// **'সব মানুষ'**
  String get allPeople;

  /// No description provided for @allTags.
  ///
  /// In bn, this message translates to:
  /// **'সব ট্যাগ'**
  String get allTags;

  /// No description provided for @filters.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার মুছুন'**
  String get clearFilters;

  /// No description provided for @noTransactionsFound.
  ///
  /// In bn, this message translates to:
  /// **'কোনো লেনদেন পাওয়া যায়নি'**
  String get noTransactionsFound;

  /// No description provided for @adjustFilters.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার পরিবর্তন করুন অথবা নতুন লেনদেন তৈরি করুন।'**
  String get adjustFilters;

  /// No description provided for @deleteTransaction.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন মুছুন?'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionNote.
  ///
  /// In bn, this message translates to:
  /// **'একটি বিপরীত এন্ট্রি যুক্ত হবে। মূল এন্ট্রি অক্ষত থাকবে।'**
  String get deleteTransactionNote;

  /// No description provided for @transactionDeleted.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন মুছে ফেলা হয়েছে'**
  String get transactionDeleted;

  /// No description provided for @transactionUpdated.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন আপডেট হয়েছে'**
  String get transactionUpdated;

  /// No description provided for @transactionSaved.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন সংরক্ষিত হয়েছে'**
  String get transactionSaved;

  /// No description provided for @editTransaction.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন সম্পাদনা'**
  String get editTransaction;

  /// No description provided for @newTransactionTitle.
  ///
  /// In bn, this message translates to:
  /// **'নতুন লেনদেন'**
  String get newTransactionTitle;

  /// No description provided for @amount.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In bn, this message translates to:
  /// **'নোট (ঐচ্ছিক)'**
  String get note;

  /// No description provided for @dateTime.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ ও সময়'**
  String get dateTime;

  /// No description provided for @tags.
  ///
  /// In bn, this message translates to:
  /// **'ট্যাগ'**
  String get tags;

  /// No description provided for @fromBucket.
  ///
  /// In bn, this message translates to:
  /// **'উৎস বাকেট'**
  String get fromBucket;

  /// No description provided for @toBucket.
  ///
  /// In bn, this message translates to:
  /// **'গন্তব্য বাকেট'**
  String get toBucket;

  /// No description provided for @from.
  ///
  /// In bn, this message translates to:
  /// **'হতে'**
  String get from;

  /// No description provided for @to.
  ///
  /// In bn, this message translates to:
  /// **'পর্যন্ত'**
  String get to;

  /// No description provided for @person.
  ///
  /// In bn, this message translates to:
  /// **'ব্যক্তি'**
  String get person;

  /// No description provided for @saveTransaction.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন সংরক্ষণ করুন'**
  String get saveTransaction;

  /// No description provided for @updateTransaction.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেন আপডেট করুন'**
  String get updateTransaction;

  /// No description provided for @enterValidAmount.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক পরিমাণ লিখুন'**
  String get enterValidAmount;

  /// No description provided for @selectSourceBucket.
  ///
  /// In bn, this message translates to:
  /// **'উৎস বাকেট নির্বাচন করুন'**
  String get selectSourceBucket;

  /// No description provided for @selectDestBucket.
  ///
  /// In bn, this message translates to:
  /// **'গন্তব্য বাকেট নির্বাচন করুন'**
  String get selectDestBucket;

  /// No description provided for @selectPerson.
  ///
  /// In bn, this message translates to:
  /// **'ব্যক্তি নির্বাচন করুন'**
  String get selectPerson;

  /// No description provided for @bucketsCannotBeSame.
  ///
  /// In bn, this message translates to:
  /// **'উৎস এবং গন্তব্য বাকেট আলাদা হতে হবে'**
  String get bucketsCannotBeSame;

  /// No description provided for @expense.
  ///
  /// In bn, this message translates to:
  /// **'খরচ'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In bn, this message translates to:
  /// **'আয়'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In bn, this message translates to:
  /// **'ট্রান্সফার'**
  String get transfer;

  /// No description provided for @loanGiven.
  ///
  /// In bn, this message translates to:
  /// **'ঋণ দেওয়া'**
  String get loanGiven;

  /// No description provided for @loanTaken.
  ///
  /// In bn, this message translates to:
  /// **'ঋণ নেওয়া'**
  String get loanTaken;

  /// No description provided for @repaymentReceived.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধ পেয়েছি'**
  String get repaymentReceived;

  /// No description provided for @repaymentPaid.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধ করেছি'**
  String get repaymentPaid;

  /// No description provided for @buckets.
  ///
  /// In bn, this message translates to:
  /// **'বাকেট'**
  String get buckets;

  /// No description provided for @newBucket.
  ///
  /// In bn, this message translates to:
  /// **'নতুন বাকেট'**
  String get newBucket;

  /// No description provided for @bucketName.
  ///
  /// In bn, this message translates to:
  /// **'বাকেটের নাম'**
  String get bucketName;

  /// No description provided for @startingBalance.
  ///
  /// In bn, this message translates to:
  /// **'প্রারম্ভিক ব্যালেন্স (৳)'**
  String get startingBalance;

  /// No description provided for @bucketCreated.
  ///
  /// In bn, this message translates to:
  /// **'বাকেট তৈরি হয়েছে'**
  String get bucketCreated;

  /// No description provided for @bucketUpdated.
  ///
  /// In bn, this message translates to:
  /// **'বাকেট আপডেট হয়েছে'**
  String get bucketUpdated;

  /// No description provided for @archived.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ করা ({count})'**
  String archived(int count);

  /// No description provided for @archiveBucket.
  ///
  /// In bn, this message translates to:
  /// **'বাকেট আর্কাইভ করবেন?'**
  String get archiveBucket;

  /// No description provided for @archiveBucketNote.
  ///
  /// In bn, this message translates to:
  /// **'{name} তালিকা থেকে লুকানো হবে। লেনদেন সংরক্ষিত থাকবে।'**
  String archiveBucketNote(String name);

  /// No description provided for @archive.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In bn, this message translates to:
  /// **'পুনরুদ্ধার'**
  String get unarchive;

  /// No description provided for @rename.
  ///
  /// In bn, this message translates to:
  /// **'নাম পরিবর্তন'**
  String get rename;

  /// No description provided for @noBucketsYet.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো বাকেট নেই। একটি তৈরি করুন!'**
  String get noBucketsYet;

  /// No description provided for @people.
  ///
  /// In bn, this message translates to:
  /// **'মানুষজন'**
  String get people;

  /// No description provided for @addPerson.
  ///
  /// In bn, this message translates to:
  /// **'মানুষ যোগ করুন'**
  String get addPerson;

  /// No description provided for @personName.
  ///
  /// In bn, this message translates to:
  /// **'নাম'**
  String get personName;

  /// No description provided for @personAdded.
  ///
  /// In bn, this message translates to:
  /// **'যোগ করা হয়েছে'**
  String get personAdded;

  /// No description provided for @personUpdated.
  ///
  /// In bn, this message translates to:
  /// **'আপডেট হয়েছে'**
  String get personUpdated;

  /// No description provided for @owesYou.
  ///
  /// In bn, this message translates to:
  /// **'আপনার কাছে {amount} পাওনা'**
  String owesYou(String amount);

  /// No description provided for @youOwe.
  ///
  /// In bn, this message translates to:
  /// **'আপনি {amount} দেনা'**
  String youOwe(String amount);

  /// No description provided for @settled.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধিত'**
  String get settled;

  /// No description provided for @noPeopleYet.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো মানুষ নেই।'**
  String get noPeopleYet;

  /// No description provided for @tagsTitle.
  ///
  /// In bn, this message translates to:
  /// **'ট্যাগ'**
  String get tagsTitle;

  /// No description provided for @newTag.
  ///
  /// In bn, this message translates to:
  /// **'নতুন ট্যাগ'**
  String get newTag;

  /// No description provided for @tagName.
  ///
  /// In bn, this message translates to:
  /// **'ট্যাগের নাম'**
  String get tagName;

  /// No description provided for @tagNameHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন: খাবার, যাতায়াত, পরিবার'**
  String get tagNameHint;

  /// No description provided for @tagCreated.
  ///
  /// In bn, this message translates to:
  /// **'ট্যাগ তৈরি হয়েছে'**
  String get tagCreated;

  /// No description provided for @tagRenamed.
  ///
  /// In bn, this message translates to:
  /// **'ট্যাগ নামান্তর হয়েছে'**
  String get tagRenamed;

  /// No description provided for @thisMonth.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে'**
  String get thisMonth;

  /// No description provided for @noTagsYet.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো ট্যাগ নেই।'**
  String get noTagsYet;

  /// No description provided for @insightsTitle.
  ///
  /// In bn, this message translates to:
  /// **'বিশ্লেষণ'**
  String get insightsTitle;

  /// No description provided for @incomeVsExpense.
  ///
  /// In bn, this message translates to:
  /// **'আয় বনাম খরচ'**
  String get incomeVsExpense;

  /// No description provided for @last6Months.
  ///
  /// In bn, this message translates to:
  /// **'গত ৬ মাস'**
  String get last6Months;

  /// No description provided for @spendingByCategory.
  ///
  /// In bn, this message translates to:
  /// **'বিভাগ অনুযায়ী খরচ'**
  String get spendingByCategory;

  /// No description provided for @bucketBalances.
  ///
  /// In bn, this message translates to:
  /// **'বাকেট ব্যালেন্স'**
  String get bucketBalances;

  /// No description provided for @live.
  ///
  /// In bn, this message translates to:
  /// **'সরাসরি'**
  String get live;

  /// No description provided for @peopleBalances.
  ///
  /// In bn, this message translates to:
  /// **'ঋণ ব্যালেন্স'**
  String get peopleBalances;

  /// No description provided for @outstandingLoans.
  ///
  /// In bn, this message translates to:
  /// **'বকেয়া ঋণ'**
  String get outstandingLoans;

  /// No description provided for @allSettledUp.
  ///
  /// In bn, this message translates to:
  /// **'সব পরিশোধিত! 🎉'**
  String get allSettledUp;

  /// No description provided for @noTaggedExpenses.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে কোনো ট্যাগযুক্ত খরচ নেই'**
  String get noTaggedExpenses;

  /// No description provided for @thisMonthChip.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস'**
  String get thisMonthChip;

  /// No description provided for @lastMonth.
  ///
  /// In bn, this message translates to:
  /// **'গত মাস'**
  String get lastMonth;

  /// No description provided for @custom.
  ///
  /// In bn, this message translates to:
  /// **'কাস্টম'**
  String get custom;

  /// No description provided for @totalLabel.
  ///
  /// In bn, this message translates to:
  /// **'মোট'**
  String get totalLabel;

  /// No description provided for @remindersTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার'**
  String get remindersTitle;

  /// No description provided for @newReminder.
  ///
  /// In bn, this message translates to:
  /// **'নতুন রিমাইন্ডার'**
  String get newReminder;

  /// No description provided for @editReminder.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার সম্পাদনা'**
  String get editReminder;

  /// No description provided for @noReminders.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো রিমাইন্ডার নেই'**
  String get noReminders;

  /// No description provided for @tapToCreate.
  ///
  /// In bn, this message translates to:
  /// **'+ দিয়ে তৈরি করুন'**
  String get tapToCreate;

  /// No description provided for @overdue.
  ///
  /// In bn, this message translates to:
  /// **'মেয়াদোত্তীর্ণ ({count})'**
  String overdue(int count);

  /// No description provided for @dueSoon.
  ///
  /// In bn, this message translates to:
  /// **'শীঘ্রই দেয় ({count})'**
  String dueSoon(int count);

  /// No description provided for @upcomingSection.
  ///
  /// In bn, this message translates to:
  /// **'আসন্ন ({count})'**
  String upcomingSection(int count);

  /// No description provided for @reminderTitle.
  ///
  /// In bn, this message translates to:
  /// **'শিরোনাম *'**
  String get reminderTitle;

  /// No description provided for @reminderAmount.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ ৳ (ঐচ্ছিক)'**
  String get reminderAmount;

  /// No description provided for @transactionType.
  ///
  /// In bn, this message translates to:
  /// **'লেনদেনের ধরন'**
  String get transactionType;

  /// No description provided for @recurrence.
  ///
  /// In bn, this message translates to:
  /// **'পুনরাবৃত্তি'**
  String get recurrence;

  /// No description provided for @once.
  ///
  /// In bn, this message translates to:
  /// **'একবার'**
  String get once;

  /// No description provided for @weekly.
  ///
  /// In bn, this message translates to:
  /// **'সাপ্তাহিক'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In bn, this message translates to:
  /// **'বার্ষিক'**
  String get yearly;

  /// No description provided for @dayOfMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাসের দিন (ঐচ্ছিক)'**
  String get dayOfMonth;

  /// No description provided for @sameasStartDate.
  ///
  /// In bn, this message translates to:
  /// **'শুরুর তারিখের মতো'**
  String get sameasStartDate;

  /// No description provided for @nextDueDate.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী তারিখ'**
  String get nextDueDate;

  /// No description provided for @linkedBucket.
  ///
  /// In bn, this message translates to:
  /// **'সংযুক্ত বাকেট (ঐচ্ছিক)'**
  String get linkedBucket;

  /// No description provided for @linkedPerson.
  ///
  /// In bn, this message translates to:
  /// **'সংযুক্ত ব্যক্তি (ঐচ্ছিক)'**
  String get linkedPerson;

  /// No description provided for @none.
  ///
  /// In bn, this message translates to:
  /// **'কোনোটি নয়'**
  String get none;

  /// No description provided for @createReminder.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার তৈরি করুন'**
  String get createReminder;

  /// No description provided for @updateReminder.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার আপডেট করুন'**
  String get updateReminder;

  /// No description provided for @reminderCreated.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার তৈরি হয়েছে'**
  String get reminderCreated;

  /// No description provided for @reminderUpdated.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার আপডেট হয়েছে'**
  String get reminderUpdated;

  /// No description provided for @titleRequired.
  ///
  /// In bn, this message translates to:
  /// **'শিরোনাম আবশ্যক'**
  String get titleRequired;

  /// No description provided for @payReminder.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধ: {title}'**
  String payReminder(String title);

  /// No description provided for @willCreateTransaction.
  ///
  /// In bn, this message translates to:
  /// **'{type} লেনদেন তৈরি হবে'**
  String willCreateTransaction(String type);

  /// No description provided for @amountLabel.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ (৳)'**
  String get amountLabel;

  /// No description provided for @noteOptional.
  ///
  /// In bn, this message translates to:
  /// **'নোট (ঐচ্ছিক)'**
  String get noteOptional;

  /// No description provided for @markAsPaid.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধ করা হয়েছে'**
  String get markAsPaid;

  /// No description provided for @paymentRecorded.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধ রেকর্ড হয়েছে!'**
  String get paymentRecorded;

  /// No description provided for @skipped.
  ///
  /// In bn, this message translates to:
  /// **'এড়িয়ে যাওয়া হয়েছে'**
  String get skipped;

  /// No description provided for @skipReminder.
  ///
  /// In bn, this message translates to:
  /// **'\"{title}\" এড়িয়ে যাবেন?'**
  String skipReminder(String title);

  /// No description provided for @nextDueWillBe.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী তারিখ হবে: {date}'**
  String nextDueWillBe(String date);

  /// No description provided for @amountNotSet.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ নির্ধারিত নয়'**
  String get amountNotSet;

  /// No description provided for @settingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get settingsTitle;

  /// No description provided for @manage.
  ///
  /// In bn, this message translates to:
  /// **'ব্যবস্থাপনা'**
  String get manage;

  /// No description provided for @bucketsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'মানি কন্টেইনার যোগ, নামান্তর, আর্কাইভ'**
  String get bucketsSubtitle;

  /// No description provided for @peopleSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'ঋণ/পরিশোধের যোগাযোগ ব্যবস্থাপনা'**
  String get peopleSubtitle;

  /// No description provided for @tagsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'ব্যয়ের বিভাগ ব্যবস্থাপনা'**
  String get tagsSubtitle;

  /// No description provided for @appearance.
  ///
  /// In bn, this message translates to:
  /// **'চেহারা'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In bn, this message translates to:
  /// **'থিম'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In bn, this message translates to:
  /// **'হালকা'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In bn, this message translates to:
  /// **'গাঢ়'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In bn, this message translates to:
  /// **'সিস্টেম'**
  String get systemTheme;

  /// No description provided for @about.
  ///
  /// In bn, this message translates to:
  /// **'সম্পর্কে'**
  String get about;

  /// No description provided for @developer.
  ///
  /// In bn, this message translates to:
  /// **'ডেভেলপার'**
  String get developer;

  /// No description provided for @developerSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'Asaduzzaman Sohel · @asadlive84'**
  String get developerSubtitle;

  /// No description provided for @advanced.
  ///
  /// In bn, this message translates to:
  /// **'উন্নত'**
  String get advanced;

  /// No description provided for @serverUrl.
  ///
  /// In bn, this message translates to:
  /// **'সার্ভার URL'**
  String get serverUrl;

  /// No description provided for @serverUrlSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'সার্ভারের ঠিকানা পরিবর্তন করুন'**
  String get serverUrlSubtitle;

  /// No description provided for @account.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট'**
  String get account;

  /// No description provided for @reportIssue.
  ///
  /// In bn, this message translates to:
  /// **'সমস্যা রিপোর্ট করুন'**
  String get reportIssue;

  /// No description provided for @reportIssueSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইলে বাগ রিপোর্ট পাঠান'**
  String get reportIssueSubtitle;

  /// No description provided for @signOut.
  ///
  /// In bn, this message translates to:
  /// **'সাইন আউট'**
  String get signOut;

  /// No description provided for @signOutSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'সেশন মুছুন এবং লগইনে ফিরুন'**
  String get signOutSubtitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In bn, this message translates to:
  /// **'সাইন আউট করবেন?'**
  String get signOutConfirm;

  /// No description provided for @signOutNote.
  ///
  /// In bn, this message translates to:
  /// **'আপনার সেশন মুছে যাবে।'**
  String get signOutNote;

  /// No description provided for @cancel.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get cancel;

  /// No description provided for @yourName2.
  ///
  /// In bn, this message translates to:
  /// **'আপনার নাম'**
  String get yourName2;

  /// No description provided for @addYourName.
  ///
  /// In bn, this message translates to:
  /// **'আপনার নাম যোগ করুন'**
  String get addYourName;

  /// No description provided for @nameAndPhone.
  ///
  /// In bn, this message translates to:
  /// **'নাম ও ফোন — সম্পাদনা করতে ট্যাপ করুন'**
  String get nameAndPhone;

  /// No description provided for @editProfile.
  ///
  /// In bn, this message translates to:
  /// **'প্রোফাইল সম্পাদনা'**
  String get editProfile;

  /// No description provided for @fullName.
  ///
  /// In bn, this message translates to:
  /// **'পূর্ণ নাম'**
  String get fullName;

  /// No description provided for @phoneOptional.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর (ঐচ্ছিক)'**
  String get phoneOptional;

  /// No description provided for @changesSavedToAccount.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তনগুলো আপনার অ্যাকাউন্টে সংরক্ষিত হবে।'**
  String get changesSavedToAccount;

  /// No description provided for @resetToDefault.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্টে ফিরুন'**
  String get resetToDefault;

  /// No description provided for @baseUrl.
  ///
  /// In bn, this message translates to:
  /// **'বেস URL'**
  String get baseUrl;

  /// No description provided for @baseUrlHint.
  ///
  /// In bn, this message translates to:
  /// **'http://আপনার-সার্ভার/v1'**
  String get baseUrlHint;

  /// No description provided for @default2.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্ট: {url}'**
  String default2(String url);

  /// No description provided for @aboutTitle.
  ///
  /// In bn, this message translates to:
  /// **'সম্পর্কে'**
  String get aboutTitle;

  /// No description provided for @developerDesigner.
  ///
  /// In bn, this message translates to:
  /// **'ডেভেলপার ও ডিজাইনার'**
  String get developerDesigner;

  /// No description provided for @emailLabel.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল'**
  String get emailLabel;

  /// No description provided for @socialLabel.
  ///
  /// In bn, this message translates to:
  /// **'সোশ্যাল'**
  String get socialLabel;

  /// No description provided for @appLabel.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপ'**
  String get appLabel;

  /// No description provided for @version.
  ///
  /// In bn, this message translates to:
  /// **'সংস্করণ'**
  String get version;

  /// No description provided for @builtWith.
  ///
  /// In bn, this message translates to:
  /// **'তৈরিতে ব্যবহৃত'**
  String get builtWith;

  /// No description provided for @madeWithLove.
  ///
  /// In bn, this message translates to:
  /// **'❤️ বাংলাদেশে তৈরি'**
  String get madeWithLove;

  /// No description provided for @copyright.
  ///
  /// In bn, this message translates to:
  /// **'© ২০২৬ Asaduzzaman Sohel'**
  String get copyright;

  /// No description provided for @noInternetConnection.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ নেই'**
  String get noInternetConnection;

  /// No description provided for @checkConnection.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ওয়াই-ফাই বা মোবাইল ডেটা\nপরীক্ষা করুন এবং আবার চেষ্টা করুন।'**
  String get checkConnection;

  /// No description provided for @serverUnavailable.
  ///
  /// In bn, this message translates to:
  /// **'সার্ভার অনুপলব্ধ'**
  String get serverUnavailable;

  /// No description provided for @serverUnavailableNote.
  ///
  /// In bn, this message translates to:
  /// **'সার্ভারে সংযোগ করতে সমস্যা হচ্ছে।\nএটি সাধারণত অস্থায়ী — আমরা ১৫ সেকেন্ড পরপর\nস্বয়ংক্রিয়ভাবে চেষ্টা করব।'**
  String get serverUnavailableNote;

  /// No description provided for @retryingAutomatically.
  ///
  /// In bn, this message translates to:
  /// **'স্বয়ংক্রিয়ভাবে চেষ্টা চলছে…'**
  String get retryingAutomatically;

  /// No description provided for @reportThisIssue.
  ///
  /// In bn, this message translates to:
  /// **'এই সমস্যা রিপোর্ট করুন'**
  String get reportThisIssue;

  /// No description provided for @saved.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষিত'**
  String get saved;

  /// No description provided for @updated.
  ///
  /// In bn, this message translates to:
  /// **'আপডেট হয়েছে'**
  String get updated;

  /// No description provided for @deleted.
  ///
  /// In bn, this message translates to:
  /// **'মুছে ফেলা হয়েছে'**
  String get deleted;

  /// No description provided for @archived2.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ হয়েছে'**
  String get archived2;

  /// No description provided for @restored.
  ///
  /// In bn, this message translates to:
  /// **'পুনরুদ্ধার হয়েছে'**
  String get restored;

  /// No description provided for @somethingWentWrong.
  ///
  /// In bn, this message translates to:
  /// **'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In bn, this message translates to:
  /// **'পুনরায় চেষ্টা'**
  String get retry;

  /// No description provided for @failedToLoad.
  ///
  /// In bn, this message translates to:
  /// **'লোড ব্যর্থ হয়েছে'**
  String get failedToLoad;

  /// No description provided for @edit.
  ///
  /// In bn, this message translates to:
  /// **'সম্পাদনা'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In bn, this message translates to:
  /// **'মুছুন'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত করুন'**
  String get confirm;

  /// No description provided for @language.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা'**
  String get language;

  /// No description provided for @bangla.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @english.
  ///
  /// In bn, this message translates to:
  /// **'English'**
  String get english;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return SBn();
    case 'en':
      return SEn();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
