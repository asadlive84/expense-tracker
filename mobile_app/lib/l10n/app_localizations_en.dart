// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Expense Tracker';

  @override
  String get appTagline => 'Your personal finance companion';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInToAccount => 'Sign in to continue';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get startTracking => 'Start tracking your finances';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordMin => 'Password (min 8 characters)';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get yourName => 'Your name (optional)';

  @override
  String get phoneNumber => 'Phone number (optional)';

  @override
  String get noAccount => 'Don\'t have an account? Create one';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get registerFailed => 'Registration failed. Please try again.';

  @override
  String get incorrectCredentials => 'Incorrect email or password.';

  @override
  String get emailAlreadyRegistered =>
      'This email is already registered. Please sign in.';

  @override
  String get cannotReachServer =>
      'Cannot reach the server. Check your connection.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters.';

  @override
  String get emailPasswordRequired => 'Email and password are required.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get ledger => 'Ledger';

  @override
  String get insights => 'Insights';

  @override
  String get reminders => 'Reminders';

  @override
  String get settings => 'Settings';

  @override
  String hi(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get expenseTracker => 'Expense Tracker';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get incomeThisMonth => 'Income (this month)';

  @override
  String get expensesThisMonth => 'Expenses (this month)';

  @override
  String get netThisMonth => 'Net (this month)';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noTransactionsYet => 'No transactions yet. Create your first one!';

  @override
  String get noUpcomingReminders => 'No upcoming reminders';

  @override
  String get whatShouldWeCallYou => 'What should we call you?';

  @override
  String get save => 'Save';

  @override
  String get pay => 'Pay';

  @override
  String get skip => 'Skip';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get transactions => 'Transactions';

  @override
  String get allMoneyMovements => 'All your money movements';

  @override
  String get add => 'Add';

  @override
  String get allTypes => 'All Types';

  @override
  String get allBuckets => 'All Buckets';

  @override
  String get allPeople => 'All People';

  @override
  String get allTags => 'All Tags';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get adjustFilters =>
      'Try adjusting your filters or create a new transaction.';

  @override
  String get deleteTransaction => 'Delete Transaction?';

  @override
  String get deleteTransactionNote =>
      'A reversal entry will be inserted. The original is kept.';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionSaved => 'Transaction saved';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get newTransactionTitle => 'New Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note (optional)';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get tags => 'Tags';

  @override
  String get fromBucket => 'From Bucket';

  @override
  String get toBucket => 'To Bucket';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get person => 'Person';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get updateTransaction => 'Update Transaction';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get selectSourceBucket => 'Please select a source bucket';

  @override
  String get selectDestBucket => 'Please select a destination bucket';

  @override
  String get selectPerson => 'Please select a person';

  @override
  String get bucketsCannotBeSame =>
      'Source and destination buckets must be different';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get loanGiven => 'Loan Given';

  @override
  String get loanTaken => 'Loan Taken';

  @override
  String get repaymentReceived => 'Repayment In';

  @override
  String get repaymentPaid => 'Repayment Out';

  @override
  String get buckets => 'Buckets';

  @override
  String get newBucket => 'New Bucket';

  @override
  String get bucketName => 'Bucket name';

  @override
  String get startingBalance => 'Starting balance (৳)';

  @override
  String get bucketCreated => 'Bucket created';

  @override
  String get bucketUpdated => 'Bucket updated';

  @override
  String archived(int count) {
    return 'Archived ($count)';
  }

  @override
  String get archiveBucket => 'Archive Bucket?';

  @override
  String archiveBucketNote(String name) {
    return '$name will be hidden from lists. Transactions are preserved.';
  }

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get rename => 'Rename';

  @override
  String get noBucketsYet => 'No buckets yet. Create one!';

  @override
  String get people => 'People';

  @override
  String get addPerson => 'Add Person';

  @override
  String get personName => 'Name';

  @override
  String get personAdded => 'Added';

  @override
  String get personUpdated => 'Updated';

  @override
  String owesYou(String amount) {
    return 'Owes you $amount';
  }

  @override
  String youOwe(String amount) {
    return 'You owe $amount';
  }

  @override
  String get settled => 'Settled';

  @override
  String get noPeopleYet => 'No people yet.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get newTag => 'New Tag';

  @override
  String get tagName => 'Tag name';

  @override
  String get tagNameHint => 'e.g. food, transport, family';

  @override
  String get tagCreated => 'Tag created';

  @override
  String get tagRenamed => 'Tag renamed';

  @override
  String get thisMonth => 'this month';

  @override
  String get noTagsYet => 'No tags yet.';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get bucketBalances => 'Bucket Balances';

  @override
  String get live => 'Live';

  @override
  String get peopleBalances => 'People Balances';

  @override
  String get outstandingLoans => 'Outstanding loans';

  @override
  String get allSettledUp => 'All settled up! 🎉';

  @override
  String get noTaggedExpenses => 'No tagged expenses this month';

  @override
  String get thisMonthChip => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get custom => 'Custom';

  @override
  String get totalLabel => 'Total';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get newReminder => 'New Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get noReminders => 'No reminders yet';

  @override
  String get tapToCreate => 'Tap + to create one';

  @override
  String overdue(int count) {
    return 'Overdue ($count)';
  }

  @override
  String dueSoon(int count) {
    return 'Due Soon ($count)';
  }

  @override
  String upcomingSection(int count) {
    return 'Upcoming ($count)';
  }

  @override
  String get reminderTitle => 'Title *';

  @override
  String get reminderAmount => 'Amount ৳ (optional)';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get recurrence => 'Recurrence';

  @override
  String get once => 'Once';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get dayOfMonth => 'Day of month (optional)';

  @override
  String get sameasStartDate => 'Same as start date';

  @override
  String get nextDueDate => 'Next due date';

  @override
  String get linkedBucket => 'Linked bucket (optional)';

  @override
  String get linkedPerson => 'Linked person (optional)';

  @override
  String get none => 'None';

  @override
  String get createReminder => 'Create Reminder';

  @override
  String get updateReminder => 'Update Reminder';

  @override
  String get reminderCreated => 'Reminder created';

  @override
  String get reminderUpdated => 'Reminder updated';

  @override
  String get titleRequired => 'Title is required';

  @override
  String payReminder(String title) {
    return 'Pay: $title';
  }

  @override
  String willCreateTransaction(String type) {
    return 'Will create a $type transaction';
  }

  @override
  String get amountLabel => 'Amount (৳)';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get paymentRecorded => 'Payment recorded!';

  @override
  String get skipped => 'Skipped';

  @override
  String skipReminder(String title) {
    return 'Skip \"$title\"?';
  }

  @override
  String nextDueWillBe(String date) {
    return 'Next due date will be: $date';
  }

  @override
  String get amountNotSet => 'Amount not set';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get manage => 'Manage';

  @override
  String get bucketsSubtitle => 'Add, rename, archive money containers';

  @override
  String get peopleSubtitle => 'Manage loan/repayment contacts';

  @override
  String get tagsSubtitle => 'Manage spending categories';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get about => 'About';

  @override
  String get developer => 'Developer';

  @override
  String get developerSubtitle => 'Asaduzzaman Sohel · @asadlive84';

  @override
  String get advanced => 'Advanced';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlSubtitle => 'Change only if your server address changed';

  @override
  String get account => 'Account';

  @override
  String get reportIssue => 'Report an Issue';

  @override
  String get reportIssueSubtitle => 'Send feedback or bug report via email';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutSubtitle => 'Clear session and return to login';

  @override
  String get signOutConfirm => 'Sign Out?';

  @override
  String get signOutNote => 'Your session will be cleared.';

  @override
  String get cancel => 'Cancel';

  @override
  String get yourName2 => 'Your Name';

  @override
  String get addYourName => 'Add your name';

  @override
  String get nameAndPhone => 'Name & phone — tap to edit';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneOptional => 'Phone number (optional)';

  @override
  String get changesSavedToAccount => 'Changes are saved to your account.';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get baseUrlHint => 'http://your-server/v1';

  @override
  String default2(String url) {
    return 'Default: $url';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get developerDesigner => 'Developer & Designer';

  @override
  String get emailLabel => 'Email';

  @override
  String get socialLabel => 'Social';

  @override
  String get appLabel => 'App';

  @override
  String get version => 'Version';

  @override
  String get builtWith => 'Built with';

  @override
  String get madeWithLove => 'Made with ❤️ in Bangladesh';

  @override
  String get copyright => '© 2026 Asaduzzaman Sohel';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get checkConnection =>
      'Please check your Wi-Fi or mobile data\nand try again.';

  @override
  String get serverUnavailable => 'Server Unavailable';

  @override
  String get serverUnavailableNote =>
      'We\'re having trouble reaching the server.\nThis is usually temporary — we\'ll retry\nautomatically every 15 seconds.';

  @override
  String get retryingAutomatically => 'Retrying automatically…';

  @override
  String get reportThisIssue => 'Report this issue';

  @override
  String get saved => 'Saved';

  @override
  String get updated => 'Updated';

  @override
  String get deleted => 'Deleted';

  @override
  String get archived2 => 'Archived';

  @override
  String get restored => 'Restored';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get language => 'Language';

  @override
  String get bangla => 'বাংলা';

  @override
  String get english => 'English';
}
