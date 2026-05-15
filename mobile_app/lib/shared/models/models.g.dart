// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagRefImpl _$$TagRefImplFromJson(Map<String, dynamic> json) => _$TagRefImpl(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$TagRefImplToJson(_$TagRefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$BucketImpl _$$BucketImplFromJson(Map<String, dynamic> json) => _$BucketImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      startingBalancePaisa: (json['starting_balance_paisa'] as num).toInt(),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$BucketImplToJson(_$BucketImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'starting_balance_paisa': instance.startingBalancePaisa,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

_$PersonImpl _$$PersonImplFromJson(Map<String, dynamic> json) => _$PersonImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$PersonImplToJson(_$PersonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      amountPaisa: (json['amount_paisa'] as num).toInt(),
      note: json['note'] as String,
      fromBucketId: json['from_bucket_id'] as String?,
      toBucketId: json['to_bucket_id'] as String?,
      personId: json['person_id'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      reversesId: json['reverses_id'] as String?,
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      reversed: json['reversed'] as bool,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'amount_paisa': instance.amountPaisa,
      'note': instance.note,
      'from_bucket_id': instance.fromBucketId,
      'to_bucket_id': instance.toBucketId,
      'person_id': instance.personId,
      'occurred_at': instance.occurredAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'reverses_id': instance.reversesId,
      'tags': instance.tags,
      'reversed': instance.reversed,
    };

_$CreateTransactionRequestImpl _$$CreateTransactionRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTransactionRequestImpl(
      type: json['type'] as String,
      amountPaisa: (json['amount_paisa'] as num).toInt(),
      fromBucketId: json['from_bucket_id'] as String?,
      toBucketId: json['to_bucket_id'] as String?,
      personId: json['person_id'] as String?,
      note: json['note'] as String? ?? '',
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      tagIds: (json['tag_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CreateTransactionRequestImplToJson(
        _$CreateTransactionRequestImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'amount_paisa': instance.amountPaisa,
      'from_bucket_id': instance.fromBucketId,
      'to_bucket_id': instance.toBucketId,
      'person_id': instance.personId,
      'note': instance.note,
      'occurred_at': instance.occurredAt.toIso8601String(),
      'tag_ids': instance.tagIds,
    };

_$BucketBalanceImpl _$$BucketBalanceImplFromJson(Map<String, dynamic> json) =>
    _$BucketBalanceImpl(
      bucketId: json['bucket_id'] as String,
      name: json['name'] as String,
      balancePaisa: (json['balance_paisa'] as num).toInt(),
    );

Map<String, dynamic> _$$BucketBalanceImplToJson(_$BucketBalanceImpl instance) =>
    <String, dynamic>{
      'bucket_id': instance.bucketId,
      'name': instance.name,
      'balance_paisa': instance.balancePaisa,
    };

_$PersonBalanceImpl _$$PersonBalanceImplFromJson(Map<String, dynamic> json) =>
    _$PersonBalanceImpl(
      personId: json['person_id'] as String,
      name: json['name'] as String,
      netPaisa: (json['net_paisa'] as num).toInt(),
    );

Map<String, dynamic> _$$PersonBalanceImplToJson(_$PersonBalanceImpl instance) =>
    <String, dynamic>{
      'person_id': instance.personId,
      'name': instance.name,
      'net_paisa': instance.netPaisa,
    };

_$TagTotalImpl _$$TagTotalImplFromJson(Map<String, dynamic> json) =>
    _$TagTotalImpl(
      tagId: json['tag_id'] as String,
      name: json['name'] as String,
      totalPaisa: (json['total_paisa'] as num).toInt(),
    );

Map<String, dynamic> _$$TagTotalImplToJson(_$TagTotalImpl instance) =>
    <String, dynamic>{
      'tag_id': instance.tagId,
      'name': instance.name,
      'total_paisa': instance.totalPaisa,
    };

_$MonthlySummaryImpl _$$MonthlySummaryImplFromJson(Map<String, dynamic> json) =>
    _$MonthlySummaryImpl(
      incomePaisa: (json['income_paisa'] as num).toInt(),
      expensePaisa: (json['expense_paisa'] as num).toInt(),
      netPaisa: (json['net_paisa'] as num).toInt(),
      byTag: (json['by_tag'] as List<dynamic>)
          .map((e) => TagTotal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MonthlySummaryImplToJson(
        _$MonthlySummaryImpl instance) =>
    <String, dynamic>{
      'income_paisa': instance.incomePaisa,
      'expense_paisa': instance.expensePaisa,
      'net_paisa': instance.netPaisa,
      'by_tag': instance.byTag,
    };

_$ReminderImpl _$$ReminderImplFromJson(Map<String, dynamic> json) =>
    _$ReminderImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      amountPaisa: (json['amount_paisa'] as num?)?.toInt(),
      defaultType: json['default_type'] as String,
      recurrenceType: json['recurrence_type'] as String,
      recurrenceDay: (json['recurrence_day'] as num?)?.toInt(),
      nextDueAt: DateTime.parse(json['next_due_at'] as String),
      linkedBucketId: json['linked_bucket_id'] as String?,
      linkedPersonId: json['linked_person_id'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ReminderImplToJson(_$ReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'amount_paisa': instance.amountPaisa,
      'default_type': instance.defaultType,
      'recurrence_type': instance.recurrenceType,
      'recurrence_day': instance.recurrenceDay,
      'next_due_at': instance.nextDueAt.toIso8601String(),
      'linked_bucket_id': instance.linkedBucketId,
      'linked_person_id': instance.linkedPersonId,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$CreateReminderRequestImpl _$$CreateReminderRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateReminderRequestImpl(
      title: json['title'] as String,
      amountPaisa: (json['amount_paisa'] as num?)?.toInt(),
      defaultType: json['default_type'] as String,
      recurrenceType: json['recurrence_type'] as String,
      recurrenceDay: (json['recurrence_day'] as num?)?.toInt(),
      nextDueAt: DateTime.parse(json['next_due_at'] as String),
      linkedBucketId: json['linked_bucket_id'] as String?,
      linkedPersonId: json['linked_person_id'] as String?,
      tagIds: (json['tag_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CreateReminderRequestImplToJson(
        _$CreateReminderRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'amount_paisa': instance.amountPaisa,
      'default_type': instance.defaultType,
      'recurrence_type': instance.recurrenceType,
      'recurrence_day': instance.recurrenceDay,
      'next_due_at': instance.nextDueAt.toIso8601String(),
      'linked_bucket_id': instance.linkedBucketId,
      'linked_person_id': instance.linkedPersonId,
      'tag_ids': instance.tagIds,
    };
