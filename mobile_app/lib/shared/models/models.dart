import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class TagRef with _$TagRef {
  const factory TagRef({
    required String id,
    required String name,
  }) = _TagRef;

  factory TagRef.fromJson(Map<String, dynamic> json) => _$TagRefFromJson(json);
}

@freezed
class Bucket with _$Bucket {
  const factory Bucket({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'starting_balance_paisa') required int startingBalancePaisa,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Bucket;

  factory Bucket.fromJson(Map<String, dynamic> json) => _$BucketFromJson(json);
}

@freezed
class Person with _$Person {
  const factory Person({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String type,
    @JsonKey(name: 'amount_paisa') required int amountPaisa,
    required String note,
    @JsonKey(name: 'from_bucket_id') String? fromBucketId,
    @JsonKey(name: 'to_bucket_id') String? toBucketId,
    @JsonKey(name: 'person_id') String? personId,
    @JsonKey(name: 'occurred_at') required DateTime occurredAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'reverses_id') String? reversesId,
    required List<TagRef> tags,
    required bool reversed,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

@freezed
class CreateTransactionRequest with _$CreateTransactionRequest {
  const factory CreateTransactionRequest({
    required String type,
    @JsonKey(name: 'amount_paisa') required int amountPaisa,
    @JsonKey(name: 'from_bucket_id') String? fromBucketId,
    @JsonKey(name: 'to_bucket_id') String? toBucketId,
    @JsonKey(name: 'person_id') String? personId,
    @Default('') String note,
    @JsonKey(name: 'occurred_at') required DateTime occurredAt,
    @JsonKey(name: 'tag_ids') @Default([]) List<String> tagIds,
  }) = _CreateTransactionRequest;

  factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionRequestFromJson(json);
}

@freezed
class BucketBalance with _$BucketBalance {
  const factory BucketBalance({
    @JsonKey(name: 'bucket_id') required String bucketId,
    required String name,
    @JsonKey(name: 'balance_paisa') required int balancePaisa,
  }) = _BucketBalance;

  factory BucketBalance.fromJson(Map<String, dynamic> json) =>
      _$BucketBalanceFromJson(json);
}

@freezed
class PersonBalance with _$PersonBalance {
  const factory PersonBalance({
    @JsonKey(name: 'person_id') required String personId,
    required String name,
    @JsonKey(name: 'net_paisa') required int netPaisa,
  }) = _PersonBalance;

  factory PersonBalance.fromJson(Map<String, dynamic> json) =>
      _$PersonBalanceFromJson(json);
}

@freezed
class TagTotal with _$TagTotal {
  const factory TagTotal({
    @JsonKey(name: 'tag_id') required String tagId,
    required String name,
    @JsonKey(name: 'total_paisa') required int totalPaisa,
  }) = _TagTotal;

  factory TagTotal.fromJson(Map<String, dynamic> json) =>
      _$TagTotalFromJson(json);
}

@freezed
class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    @JsonKey(name: 'income_paisa') required int incomePaisa,
    @JsonKey(name: 'expense_paisa') required int expensePaisa,
    @JsonKey(name: 'net_paisa') required int netPaisa,
    @JsonKey(name: 'by_tag') required List<TagTotal> byTag,
  }) = _MonthlySummary;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(json);
}

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    @JsonKey(name: 'amount_paisa') int? amountPaisa,
    @JsonKey(name: 'default_type') required String defaultType,
    @JsonKey(name: 'recurrence_type') required String recurrenceType,
    @JsonKey(name: 'recurrence_day') int? recurrenceDay,
    @JsonKey(name: 'next_due_at') required DateTime nextDueAt,
    @JsonKey(name: 'linked_bucket_id') String? linkedBucketId,
    @JsonKey(name: 'linked_person_id') String? linkedPersonId,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}

@freezed
class CreateReminderRequest with _$CreateReminderRequest {
  const factory CreateReminderRequest({
    required String title,
    @JsonKey(name: 'amount_paisa') int? amountPaisa,
    @JsonKey(name: 'default_type') required String defaultType,
    @JsonKey(name: 'recurrence_type') required String recurrenceType,
    @JsonKey(name: 'recurrence_day') int? recurrenceDay,
    @JsonKey(name: 'next_due_at') required DateTime nextDueAt,
    @JsonKey(name: 'linked_bucket_id') String? linkedBucketId,
    @JsonKey(name: 'linked_person_id') String? linkedPersonId,
    @JsonKey(name: 'tag_ids') @Default([]) List<String> tagIds,
  }) = _CreateReminderRequest;

  factory CreateReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReminderRequestFromJson(json);
}
