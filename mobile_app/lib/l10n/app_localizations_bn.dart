// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class SBn extends S {
  SBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'এক্সপেন্স ট্র্যাকার';

  @override
  String get appTagline => 'আপনার ব্যক্তিগত অর্থ ব্যবস্থাপক';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get signInToAccount => 'আপনার অ্যাকাউন্টে সাইন ইন করুন';

  @override
  String get signUp => 'সাইন আপ';

  @override
  String get createAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get startTracking => 'আপনার অর্থ ট্র্যাক শুরু করুন';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get passwordMin => 'পাসওয়ার্ড (কমপক্ষে ৮ অক্ষর)';

  @override
  String get confirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get yourName => 'আপনার নাম (ঐচ্ছিক)';

  @override
  String get phoneNumber => 'ফোন নম্বর (ঐচ্ছিক)';

  @override
  String get noAccount => 'অ্যাকাউন্ট নেই? তৈরি করুন';

  @override
  String get haveAccount => 'ইতিমধ্যে অ্যাকাউন্ট আছে? সাইন ইন করুন';

  @override
  String get loginFailed => 'লগইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get registerFailed => 'নিবন্ধন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get incorrectCredentials => 'ইমেইল বা পাসওয়ার্ড ভুল।';

  @override
  String get emailAlreadyRegistered =>
      'এই ইমেইল ইতিমধ্যে নিবন্ধিত। সাইন ইন করুন।';

  @override
  String get cannotReachServer =>
      'সার্ভারে সংযোগ করা যাচ্ছে না। আপনার সংযোগ পরীক্ষা করুন।';

  @override
  String get serverError => 'সার্ভার সমস্যা। পরে আবার চেষ্টা করুন।';

  @override
  String get passwordsDoNotMatch => 'পাসওয়ার্ড মিলছে না।';

  @override
  String get passwordTooShort => 'পাসওয়ার্ড কমপক্ষে ৮ অক্ষর হতে হবে।';

  @override
  String get emailPasswordRequired => 'ইমেইল এবং পাসওয়ার্ড আবশ্যক।';

  @override
  String get dashboard => 'ড্যাশবোর্ড';

  @override
  String get ledger => 'লেনদেন';

  @override
  String get insights => 'বিশ্লেষণ';

  @override
  String get reminders => 'রিমাইন্ডার';

  @override
  String get settings => 'সেটিংস';

  @override
  String hi(String name) {
    return 'হ্যালো, $name 👋';
  }

  @override
  String get expenseTracker => 'এক্সপেন্স ট্র্যাকার';

  @override
  String get totalBalance => 'মোট ব্যালেন্স';

  @override
  String get incomeThisMonth => 'এই মাসের আয়';

  @override
  String get expensesThisMonth => 'এই মাসের খরচ';

  @override
  String get netThisMonth => 'এই মাসের নেট';

  @override
  String get recentTransactions => 'সাম্প্রতিক লেনদেন';

  @override
  String get upcoming => 'আসন্ন';

  @override
  String get noTransactionsYet => 'এখনো কোনো লেনদেন নেই। প্রথমটি তৈরি করুন!';

  @override
  String get noUpcomingReminders => 'কোনো আসন্ন রিমাইন্ডার নেই';

  @override
  String get whatShouldWeCallYou => 'আমরা আপনাকে কী নামে ডাকব?';

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get pay => 'পরিশোধ';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get newTransaction => 'নতুন লেনদেন';

  @override
  String get transactions => 'লেনদেন';

  @override
  String get allMoneyMovements => 'সকল লেনদেন';

  @override
  String get add => 'যোগ করুন';

  @override
  String get allTypes => 'সব ধরন';

  @override
  String get allBuckets => 'সব বাকেট';

  @override
  String get allPeople => 'সব মানুষ';

  @override
  String get allTags => 'সব ট্যাগ';

  @override
  String get filters => 'ফিল্টার';

  @override
  String get clearFilters => 'ফিল্টার মুছুন';

  @override
  String get noTransactionsFound => 'কোনো লেনদেন পাওয়া যায়নি';

  @override
  String get adjustFilters =>
      'ফিল্টার পরিবর্তন করুন অথবা নতুন লেনদেন তৈরি করুন।';

  @override
  String get deleteTransaction => 'লেনদেন মুছুন?';

  @override
  String get deleteTransactionNote =>
      'একটি বিপরীত এন্ট্রি যুক্ত হবে। মূল এন্ট্রি অক্ষত থাকবে।';

  @override
  String get transactionDeleted => 'লেনদেন মুছে ফেলা হয়েছে';

  @override
  String get transactionUpdated => 'লেনদেন আপডেট হয়েছে';

  @override
  String get transactionSaved => 'লেনদেন সংরক্ষিত হয়েছে';

  @override
  String get editTransaction => 'লেনদেন সম্পাদনা';

  @override
  String get newTransactionTitle => 'নতুন লেনদেন';

  @override
  String get amount => 'পরিমাণ';

  @override
  String get note => 'নোট (ঐচ্ছিক)';

  @override
  String get dateTime => 'তারিখ ও সময়';

  @override
  String get tags => 'ট্যাগ';

  @override
  String get fromBucket => 'উৎস বাকেট';

  @override
  String get toBucket => 'গন্তব্য বাকেট';

  @override
  String get from => 'হতে';

  @override
  String get to => 'পর্যন্ত';

  @override
  String get person => 'ব্যক্তি';

  @override
  String get saveTransaction => 'লেনদেন সংরক্ষণ করুন';

  @override
  String get updateTransaction => 'লেনদেন আপডেট করুন';

  @override
  String get enterValidAmount => 'সঠিক পরিমাণ লিখুন';

  @override
  String get selectSourceBucket => 'উৎস বাকেট নির্বাচন করুন';

  @override
  String get selectDestBucket => 'গন্তব্য বাকেট নির্বাচন করুন';

  @override
  String get selectPerson => 'ব্যক্তি নির্বাচন করুন';

  @override
  String get bucketsCannotBeSame => 'উৎস এবং গন্তব্য বাকেট আলাদা হতে হবে';

  @override
  String get expense => 'খরচ';

  @override
  String get income => 'আয়';

  @override
  String get transfer => 'ট্রান্সফার';

  @override
  String get loanGiven => 'ঋণ দেওয়া';

  @override
  String get loanTaken => 'ঋণ নেওয়া';

  @override
  String get repaymentReceived => 'পরিশোধ পেয়েছি';

  @override
  String get repaymentPaid => 'পরিশোধ করেছি';

  @override
  String get buckets => 'বাকেট';

  @override
  String get newBucket => 'নতুন বাকেট';

  @override
  String get bucketName => 'বাকেটের নাম';

  @override
  String get startingBalance => 'প্রারম্ভিক ব্যালেন্স (৳)';

  @override
  String get bucketCreated => 'বাকেট তৈরি হয়েছে';

  @override
  String get bucketUpdated => 'বাকেট আপডেট হয়েছে';

  @override
  String archived(int count) {
    return 'আর্কাইভ করা ($count)';
  }

  @override
  String get archiveBucket => 'বাকেট আর্কাইভ করবেন?';

  @override
  String archiveBucketNote(String name) {
    return '$name তালিকা থেকে লুকানো হবে। লেনদেন সংরক্ষিত থাকবে।';
  }

  @override
  String get archive => 'আর্কাইভ';

  @override
  String get unarchive => 'পুনরুদ্ধার';

  @override
  String get rename => 'নাম পরিবর্তন';

  @override
  String get noBucketsYet => 'এখনো কোনো বাকেট নেই। একটি তৈরি করুন!';

  @override
  String get people => 'মানুষজন';

  @override
  String get addPerson => 'মানুষ যোগ করুন';

  @override
  String get personName => 'নাম';

  @override
  String get personAdded => 'যোগ করা হয়েছে';

  @override
  String get personUpdated => 'আপডেট হয়েছে';

  @override
  String owesYou(String amount) {
    return 'আপনার কাছে $amount পাওনা';
  }

  @override
  String youOwe(String amount) {
    return 'আপনি $amount দেনা';
  }

  @override
  String get settled => 'পরিশোধিত';

  @override
  String get noPeopleYet => 'এখনো কোনো মানুষ নেই।';

  @override
  String get tagsTitle => 'ট্যাগ';

  @override
  String get newTag => 'নতুন ট্যাগ';

  @override
  String get tagName => 'ট্যাগের নাম';

  @override
  String get tagNameHint => 'যেমন: খাবার, যাতায়াত, পরিবার';

  @override
  String get tagCreated => 'ট্যাগ তৈরি হয়েছে';

  @override
  String get tagRenamed => 'ট্যাগ নামান্তর হয়েছে';

  @override
  String get thisMonth => 'এই মাসে';

  @override
  String get noTagsYet => 'এখনো কোনো ট্যাগ নেই।';

  @override
  String get insightsTitle => 'বিশ্লেষণ';

  @override
  String get incomeVsExpense => 'আয় বনাম খরচ';

  @override
  String get last6Months => 'গত ৬ মাস';

  @override
  String get spendingByCategory => 'বিভাগ অনুযায়ী খরচ';

  @override
  String get bucketBalances => 'বাকেট ব্যালেন্স';

  @override
  String get live => 'সরাসরি';

  @override
  String get peopleBalances => 'ঋণ ব্যালেন্স';

  @override
  String get outstandingLoans => 'বকেয়া ঋণ';

  @override
  String get allSettledUp => 'সব পরিশোধিত! 🎉';

  @override
  String get noTaggedExpenses => 'এই মাসে কোনো ট্যাগযুক্ত খরচ নেই';

  @override
  String get thisMonthChip => 'এই মাস';

  @override
  String get lastMonth => 'গত মাস';

  @override
  String get custom => 'কাস্টম';

  @override
  String get totalLabel => 'মোট';

  @override
  String get remindersTitle => 'রিমাইন্ডার';

  @override
  String get newReminder => 'নতুন রিমাইন্ডার';

  @override
  String get editReminder => 'রিমাইন্ডার সম্পাদনা';

  @override
  String get noReminders => 'এখনো কোনো রিমাইন্ডার নেই';

  @override
  String get tapToCreate => '+ দিয়ে তৈরি করুন';

  @override
  String overdue(int count) {
    return 'মেয়াদোত্তীর্ণ ($count)';
  }

  @override
  String dueSoon(int count) {
    return 'শীঘ্রই দেয় ($count)';
  }

  @override
  String upcomingSection(int count) {
    return 'আসন্ন ($count)';
  }

  @override
  String get reminderTitle => 'শিরোনাম *';

  @override
  String get reminderAmount => 'পরিমাণ ৳ (ঐচ্ছিক)';

  @override
  String get transactionType => 'লেনদেনের ধরন';

  @override
  String get recurrence => 'পুনরাবৃত্তি';

  @override
  String get once => 'একবার';

  @override
  String get weekly => 'সাপ্তাহিক';

  @override
  String get monthly => 'মাসিক';

  @override
  String get yearly => 'বার্ষিক';

  @override
  String get dayOfMonth => 'মাসের দিন (ঐচ্ছিক)';

  @override
  String get sameasStartDate => 'শুরুর তারিখের মতো';

  @override
  String get nextDueDate => 'পরবর্তী তারিখ';

  @override
  String get linkedBucket => 'সংযুক্ত বাকেট (ঐচ্ছিক)';

  @override
  String get linkedPerson => 'সংযুক্ত ব্যক্তি (ঐচ্ছিক)';

  @override
  String get none => 'কোনোটি নয়';

  @override
  String get createReminder => 'রিমাইন্ডার তৈরি করুন';

  @override
  String get updateReminder => 'রিমাইন্ডার আপডেট করুন';

  @override
  String get reminderCreated => 'রিমাইন্ডার তৈরি হয়েছে';

  @override
  String get reminderUpdated => 'রিমাইন্ডার আপডেট হয়েছে';

  @override
  String get titleRequired => 'শিরোনাম আবশ্যক';

  @override
  String payReminder(String title) {
    return 'পরিশোধ: $title';
  }

  @override
  String willCreateTransaction(String type) {
    return '$type লেনদেন তৈরি হবে';
  }

  @override
  String get amountLabel => 'পরিমাণ (৳)';

  @override
  String get noteOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get markAsPaid => 'পরিশোধ করা হয়েছে';

  @override
  String get paymentRecorded => 'পরিশোধ রেকর্ড হয়েছে!';

  @override
  String get skipped => 'এড়িয়ে যাওয়া হয়েছে';

  @override
  String skipReminder(String title) {
    return '\"$title\" এড়িয়ে যাবেন?';
  }

  @override
  String nextDueWillBe(String date) {
    return 'পরবর্তী তারিখ হবে: $date';
  }

  @override
  String get amountNotSet => 'পরিমাণ নির্ধারিত নয়';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get manage => 'ব্যবস্থাপনা';

  @override
  String get bucketsSubtitle => 'মানি কন্টেইনার যোগ, নামান্তর, আর্কাইভ';

  @override
  String get peopleSubtitle => 'ঋণ/পরিশোধের যোগাযোগ ব্যবস্থাপনা';

  @override
  String get tagsSubtitle => 'ব্যয়ের বিভাগ ব্যবস্থাপনা';

  @override
  String get appearance => 'চেহারা';

  @override
  String get theme => 'থিম';

  @override
  String get lightTheme => 'হালকা';

  @override
  String get darkTheme => 'গাঢ়';

  @override
  String get systemTheme => 'সিস্টেম';

  @override
  String get about => 'সম্পর্কে';

  @override
  String get developer => 'ডেভেলপার';

  @override
  String get developerSubtitle => 'Asaduzzaman Sohel · @asadlive84';

  @override
  String get advanced => 'উন্নত';

  @override
  String get serverUrl => 'সার্ভার URL';

  @override
  String get serverUrlSubtitle => 'সার্ভারের ঠিকানা পরিবর্তন করুন';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get reportIssue => 'সমস্যা রিপোর্ট করুন';

  @override
  String get reportIssueSubtitle => 'ইমেইলে বাগ রিপোর্ট পাঠান';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get signOutSubtitle => 'সেশন মুছুন এবং লগইনে ফিরুন';

  @override
  String get signOutConfirm => 'সাইন আউট করবেন?';

  @override
  String get signOutNote => 'আপনার সেশন মুছে যাবে।';

  @override
  String get cancel => 'বাতিল';

  @override
  String get yourName2 => 'আপনার নাম';

  @override
  String get addYourName => 'আপনার নাম যোগ করুন';

  @override
  String get nameAndPhone => 'নাম ও ফোন — সম্পাদনা করতে ট্যাপ করুন';

  @override
  String get editProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get fullName => 'পূর্ণ নাম';

  @override
  String get phoneOptional => 'ফোন নম্বর (ঐচ্ছিক)';

  @override
  String get changesSavedToAccount =>
      'পরিবর্তনগুলো আপনার অ্যাকাউন্টে সংরক্ষিত হবে।';

  @override
  String get resetToDefault => 'ডিফল্টে ফিরুন';

  @override
  String get baseUrl => 'বেস URL';

  @override
  String get baseUrlHint => 'http://আপনার-সার্ভার/v1';

  @override
  String default2(String url) {
    return 'ডিফল্ট: $url';
  }

  @override
  String get aboutTitle => 'সম্পর্কে';

  @override
  String get developerDesigner => 'ডেভেলপার ও ডিজাইনার';

  @override
  String get emailLabel => 'ইমেইল';

  @override
  String get socialLabel => 'সোশ্যাল';

  @override
  String get appLabel => 'অ্যাপ';

  @override
  String get version => 'সংস্করণ';

  @override
  String get builtWith => 'তৈরিতে ব্যবহৃত';

  @override
  String get madeWithLove => '❤️ বাংলাদেশে তৈরি';

  @override
  String get copyright => '© ২০২৬ Asaduzzaman Sohel';

  @override
  String get noInternetConnection => 'ইন্টারনেট সংযোগ নেই';

  @override
  String get checkConnection =>
      'আপনার ওয়াই-ফাই বা মোবাইল ডেটা\nপরীক্ষা করুন এবং আবার চেষ্টা করুন।';

  @override
  String get serverUnavailable => 'সার্ভার অনুপলব্ধ';

  @override
  String get serverUnavailableNote =>
      'সার্ভারে সংযোগ করতে সমস্যা হচ্ছে।\nএটি সাধারণত অস্থায়ী — আমরা ১৫ সেকেন্ড পরপর\nস্বয়ংক্রিয়ভাবে চেষ্টা করব।';

  @override
  String get retryingAutomatically => 'স্বয়ংক্রিয়ভাবে চেষ্টা চলছে…';

  @override
  String get reportThisIssue => 'এই সমস্যা রিপোর্ট করুন';

  @override
  String get saved => 'সংরক্ষিত';

  @override
  String get updated => 'আপডেট হয়েছে';

  @override
  String get deleted => 'মুছে ফেলা হয়েছে';

  @override
  String get archived2 => 'আর্কাইভ হয়েছে';

  @override
  String get restored => 'পুনরুদ্ধার হয়েছে';

  @override
  String get somethingWentWrong => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get retry => 'পুনরায় চেষ্টা';

  @override
  String get failedToLoad => 'লোড ব্যর্থ হয়েছে';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get delete => 'মুছুন';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get language => 'ভাষা';

  @override
  String get bangla => 'বাংলা';

  @override
  String get english => 'English';
}
