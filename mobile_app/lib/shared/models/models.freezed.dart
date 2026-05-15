// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TagRef _$TagRefFromJson(Map<String, dynamic> json) {
  return _TagRef.fromJson(json);
}

/// @nodoc
mixin _$TagRef {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this TagRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TagRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagRefCopyWith<TagRef> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagRefCopyWith<$Res> {
  factory $TagRefCopyWith(TagRef value, $Res Function(TagRef) then) =
      _$TagRefCopyWithImpl<$Res, TagRef>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$TagRefCopyWithImpl<$Res, $Val extends TagRef>
    implements $TagRefCopyWith<$Res> {
  _$TagRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TagRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TagRefImplCopyWith<$Res> implements $TagRefCopyWith<$Res> {
  factory _$$TagRefImplCopyWith(
          _$TagRefImpl value, $Res Function(_$TagRefImpl) then) =
      __$$TagRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$TagRefImplCopyWithImpl<$Res>
    extends _$TagRefCopyWithImpl<$Res, _$TagRefImpl>
    implements _$$TagRefImplCopyWith<$Res> {
  __$$TagRefImplCopyWithImpl(
      _$TagRefImpl _value, $Res Function(_$TagRefImpl) _then)
      : super(_value, _then);

  /// Create a copy of TagRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$TagRefImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TagRefImpl implements _TagRef {
  const _$TagRefImpl({required this.id, required this.name});

  factory _$TagRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagRefImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'TagRef(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of TagRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagRefImplCopyWith<_$TagRefImpl> get copyWith =>
      __$$TagRefImplCopyWithImpl<_$TagRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagRefImplToJson(
      this,
    );
  }
}

abstract class _TagRef implements TagRef {
  const factory _TagRef(
      {required final String id, required final String name}) = _$TagRefImpl;

  factory _TagRef.fromJson(Map<String, dynamic> json) = _$TagRefImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of TagRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagRefImplCopyWith<_$TagRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Bucket _$BucketFromJson(Map<String, dynamic> json) {
  return _Bucket.fromJson(json);
}

/// @nodoc
mixin _$Bucket {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'starting_balance_paisa')
  int get startingBalancePaisa => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Bucket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BucketCopyWith<Bucket> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BucketCopyWith<$Res> {
  factory $BucketCopyWith(Bucket value, $Res Function(Bucket) then) =
      _$BucketCopyWithImpl<$Res, Bucket>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'starting_balance_paisa') int startingBalancePaisa,
      @JsonKey(name: 'archived_at') DateTime? archivedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$BucketCopyWithImpl<$Res, $Val extends Bucket>
    implements $BucketCopyWith<$Res> {
  _$BucketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? startingBalancePaisa = null,
    Object? archivedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startingBalancePaisa: null == startingBalancePaisa
          ? _value.startingBalancePaisa
          : startingBalancePaisa // ignore: cast_nullable_to_non_nullable
              as int,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BucketImplCopyWith<$Res> implements $BucketCopyWith<$Res> {
  factory _$$BucketImplCopyWith(
          _$BucketImpl value, $Res Function(_$BucketImpl) then) =
      __$$BucketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'starting_balance_paisa') int startingBalancePaisa,
      @JsonKey(name: 'archived_at') DateTime? archivedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$BucketImplCopyWithImpl<$Res>
    extends _$BucketCopyWithImpl<$Res, _$BucketImpl>
    implements _$$BucketImplCopyWith<$Res> {
  __$$BucketImplCopyWithImpl(
      _$BucketImpl _value, $Res Function(_$BucketImpl) _then)
      : super(_value, _then);

  /// Create a copy of Bucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? startingBalancePaisa = null,
    Object? archivedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$BucketImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startingBalancePaisa: null == startingBalancePaisa
          ? _value.startingBalancePaisa
          : startingBalancePaisa // ignore: cast_nullable_to_non_nullable
              as int,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BucketImpl implements _Bucket {
  const _$BucketImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.name,
      @JsonKey(name: 'starting_balance_paisa')
      required this.startingBalancePaisa,
      @JsonKey(name: 'archived_at') this.archivedAt,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$BucketImpl.fromJson(Map<String, dynamic> json) =>
      _$$BucketImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'starting_balance_paisa')
  final int startingBalancePaisa;
  @override
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Bucket(id: $id, userId: $userId, name: $name, startingBalancePaisa: $startingBalancePaisa, archivedAt: $archivedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BucketImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startingBalancePaisa, startingBalancePaisa) ||
                other.startingBalancePaisa == startingBalancePaisa) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name,
      startingBalancePaisa, archivedAt, createdAt);

  /// Create a copy of Bucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BucketImplCopyWith<_$BucketImpl> get copyWith =>
      __$$BucketImplCopyWithImpl<_$BucketImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BucketImplToJson(
      this,
    );
  }
}

abstract class _Bucket implements Bucket {
  const factory _Bucket(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String name,
          @JsonKey(name: 'starting_balance_paisa')
          required final int startingBalancePaisa,
          @JsonKey(name: 'archived_at') final DateTime? archivedAt,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$BucketImpl;

  factory _Bucket.fromJson(Map<String, dynamic> json) = _$BucketImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'starting_balance_paisa')
  int get startingBalancePaisa;
  @override
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Bucket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BucketImplCopyWith<_$BucketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Person _$PersonFromJson(Map<String, dynamic> json) {
  return _Person.fromJson(json);
}

/// @nodoc
mixin _$Person {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Person to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonCopyWith<Person> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonCopyWith<$Res> {
  factory $PersonCopyWith(Person value, $Res Function(Person) then) =
      _$PersonCopyWithImpl<$Res, Person>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'archived_at') DateTime? archivedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$PersonCopyWithImpl<$Res, $Val extends Person>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? archivedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonImplCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$$PersonImplCopyWith(
          _$PersonImpl value, $Res Function(_$PersonImpl) then) =
      __$$PersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'archived_at') DateTime? archivedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$PersonImplCopyWithImpl<$Res>
    extends _$PersonCopyWithImpl<$Res, _$PersonImpl>
    implements _$$PersonImplCopyWith<$Res> {
  __$$PersonImplCopyWithImpl(
      _$PersonImpl _value, $Res Function(_$PersonImpl) _then)
      : super(_value, _then);

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? archivedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$PersonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonImpl implements _Person {
  const _$PersonImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.name,
      @JsonKey(name: 'archived_at') this.archivedAt,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$PersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Person(id: $id, userId: $userId, name: $name, archivedAt: $archivedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, name, archivedAt, createdAt);

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      __$$PersonImplCopyWithImpl<_$PersonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonImplToJson(
      this,
    );
  }
}

abstract class _Person implements Person {
  const factory _Person(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String name,
          @JsonKey(name: 'archived_at') final DateTime? archivedAt,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$PersonImpl;

  factory _Person.fromJson(Map<String, dynamic> json) = _$PersonImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Person
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'archived_at') DateTime? archivedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? archivedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TagImplCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$TagImplCopyWith(_$TagImpl value, $Res Function(_$TagImpl) then) =
      __$$TagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'archived_at') DateTime? archivedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TagImplCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res, _$TagImpl>
    implements _$$TagImplCopyWith<$Res> {
  __$$TagImplCopyWithImpl(_$TagImpl _value, $Res Function(_$TagImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? archivedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$TagImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TagImpl implements _Tag {
  const _$TagImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.name,
      @JsonKey(name: 'archived_at') this.archivedAt,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TagImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Tag(id: $id, userId: $userId, name: $name, archivedAt: $archivedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, name, archivedAt, createdAt);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      __$$TagImplCopyWithImpl<_$TagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagImplToJson(
      this,
    );
  }
}

abstract class _Tag implements Tag {
  const factory _Tag(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String name,
          @JsonKey(name: 'archived_at') final DateTime? archivedAt,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TagImpl;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$TagImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paisa')
  int get amountPaisa => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_bucket_id')
  String? get fromBucketId => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_bucket_id')
  String? get toBucketId => throw _privateConstructorUsedError;
  @JsonKey(name: 'person_id')
  String? get personId => throw _privateConstructorUsedError;
  @JsonKey(name: 'occurred_at')
  DateTime get occurredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'reverses_id')
  String? get reversesId => throw _privateConstructorUsedError;
  List<TagRef> get tags => throw _privateConstructorUsedError;
  bool get reversed => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String type,
      @JsonKey(name: 'amount_paisa') int amountPaisa,
      String note,
      @JsonKey(name: 'from_bucket_id') String? fromBucketId,
      @JsonKey(name: 'to_bucket_id') String? toBucketId,
      @JsonKey(name: 'person_id') String? personId,
      @JsonKey(name: 'occurred_at') DateTime occurredAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'reverses_id') String? reversesId,
      List<TagRef> tags,
      bool reversed});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amountPaisa = null,
    Object? note = null,
    Object? fromBucketId = freezed,
    Object? toBucketId = freezed,
    Object? personId = freezed,
    Object? occurredAt = null,
    Object? createdAt = null,
    Object? reversesId = freezed,
    Object? tags = null,
    Object? reversed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: null == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      fromBucketId: freezed == fromBucketId
          ? _value.fromBucketId
          : fromBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      toBucketId: freezed == toBucketId
          ? _value.toBucketId
          : toBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      personId: freezed == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String?,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reversesId: freezed == reversesId
          ? _value.reversesId
          : reversesId // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<TagRef>,
      reversed: null == reversed
          ? _value.reversed
          : reversed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String type,
      @JsonKey(name: 'amount_paisa') int amountPaisa,
      String note,
      @JsonKey(name: 'from_bucket_id') String? fromBucketId,
      @JsonKey(name: 'to_bucket_id') String? toBucketId,
      @JsonKey(name: 'person_id') String? personId,
      @JsonKey(name: 'occurred_at') DateTime occurredAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'reverses_id') String? reversesId,
      List<TagRef> tags,
      bool reversed});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amountPaisa = null,
    Object? note = null,
    Object? fromBucketId = freezed,
    Object? toBucketId = freezed,
    Object? personId = freezed,
    Object? occurredAt = null,
    Object? createdAt = null,
    Object? reversesId = freezed,
    Object? tags = null,
    Object? reversed = null,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: null == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      fromBucketId: freezed == fromBucketId
          ? _value.fromBucketId
          : fromBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      toBucketId: freezed == toBucketId
          ? _value.toBucketId
          : toBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      personId: freezed == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String?,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reversesId: freezed == reversesId
          ? _value.reversesId
          : reversesId // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<TagRef>,
      reversed: null == reversed
          ? _value.reversed
          : reversed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.type,
      @JsonKey(name: 'amount_paisa') required this.amountPaisa,
      required this.note,
      @JsonKey(name: 'from_bucket_id') this.fromBucketId,
      @JsonKey(name: 'to_bucket_id') this.toBucketId,
      @JsonKey(name: 'person_id') this.personId,
      @JsonKey(name: 'occurred_at') required this.occurredAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'reverses_id') this.reversesId,
      required final List<TagRef> tags,
      required this.reversed})
      : _tags = tags;

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String type;
  @override
  @JsonKey(name: 'amount_paisa')
  final int amountPaisa;
  @override
  final String note;
  @override
  @JsonKey(name: 'from_bucket_id')
  final String? fromBucketId;
  @override
  @JsonKey(name: 'to_bucket_id')
  final String? toBucketId;
  @override
  @JsonKey(name: 'person_id')
  final String? personId;
  @override
  @JsonKey(name: 'occurred_at')
  final DateTime occurredAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'reverses_id')
  final String? reversesId;
  final List<TagRef> _tags;
  @override
  List<TagRef> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final bool reversed;

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, type: $type, amountPaisa: $amountPaisa, note: $note, fromBucketId: $fromBucketId, toBucketId: $toBucketId, personId: $personId, occurredAt: $occurredAt, createdAt: $createdAt, reversesId: $reversesId, tags: $tags, reversed: $reversed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amountPaisa, amountPaisa) ||
                other.amountPaisa == amountPaisa) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.fromBucketId, fromBucketId) ||
                other.fromBucketId == fromBucketId) &&
            (identical(other.toBucketId, toBucketId) ||
                other.toBucketId == toBucketId) &&
            (identical(other.personId, personId) ||
                other.personId == personId) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.reversesId, reversesId) ||
                other.reversesId == reversesId) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.reversed, reversed) ||
                other.reversed == reversed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      type,
      amountPaisa,
      note,
      fromBucketId,
      toBucketId,
      personId,
      occurredAt,
      createdAt,
      reversesId,
      const DeepCollectionEquality().hash(_tags),
      reversed);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      required final String type,
      @JsonKey(name: 'amount_paisa') required final int amountPaisa,
      required final String note,
      @JsonKey(name: 'from_bucket_id') final String? fromBucketId,
      @JsonKey(name: 'to_bucket_id') final String? toBucketId,
      @JsonKey(name: 'person_id') final String? personId,
      @JsonKey(name: 'occurred_at') required final DateTime occurredAt,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'reverses_id') final String? reversesId,
      required final List<TagRef> tags,
      required final bool reversed}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get type;
  @override
  @JsonKey(name: 'amount_paisa')
  int get amountPaisa;
  @override
  String get note;
  @override
  @JsonKey(name: 'from_bucket_id')
  String? get fromBucketId;
  @override
  @JsonKey(name: 'to_bucket_id')
  String? get toBucketId;
  @override
  @JsonKey(name: 'person_id')
  String? get personId;
  @override
  @JsonKey(name: 'occurred_at')
  DateTime get occurredAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'reverses_id')
  String? get reversesId;
  @override
  List<TagRef> get tags;
  @override
  bool get reversed;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateTransactionRequest _$CreateTransactionRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateTransactionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateTransactionRequest {
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paisa')
  int get amountPaisa => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_bucket_id')
  String? get fromBucketId => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_bucket_id')
  String? get toBucketId => throw _privateConstructorUsedError;
  @JsonKey(name: 'person_id')
  String? get personId => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'occurred_at')
  DateTime get occurredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'tag_ids')
  List<String> get tagIds => throw _privateConstructorUsedError;

  /// Serializes this CreateTransactionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTransactionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTransactionRequestCopyWith<CreateTransactionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTransactionRequestCopyWith<$Res> {
  factory $CreateTransactionRequestCopyWith(CreateTransactionRequest value,
          $Res Function(CreateTransactionRequest) then) =
      _$CreateTransactionRequestCopyWithImpl<$Res, CreateTransactionRequest>;
  @useResult
  $Res call(
      {String type,
      @JsonKey(name: 'amount_paisa') int amountPaisa,
      @JsonKey(name: 'from_bucket_id') String? fromBucketId,
      @JsonKey(name: 'to_bucket_id') String? toBucketId,
      @JsonKey(name: 'person_id') String? personId,
      String note,
      @JsonKey(name: 'occurred_at') DateTime occurredAt,
      @JsonKey(name: 'tag_ids') List<String> tagIds});
}

/// @nodoc
class _$CreateTransactionRequestCopyWithImpl<$Res,
        $Val extends CreateTransactionRequest>
    implements $CreateTransactionRequestCopyWith<$Res> {
  _$CreateTransactionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTransactionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? amountPaisa = null,
    Object? fromBucketId = freezed,
    Object? toBucketId = freezed,
    Object? personId = freezed,
    Object? note = null,
    Object? occurredAt = null,
    Object? tagIds = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: null == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int,
      fromBucketId: freezed == fromBucketId
          ? _value.fromBucketId
          : fromBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      toBucketId: freezed == toBucketId
          ? _value.toBucketId
          : toBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      personId: freezed == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String?,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tagIds: null == tagIds
          ? _value.tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateTransactionRequestImplCopyWith<$Res>
    implements $CreateTransactionRequestCopyWith<$Res> {
  factory _$$CreateTransactionRequestImplCopyWith(
          _$CreateTransactionRequestImpl value,
          $Res Function(_$CreateTransactionRequestImpl) then) =
      __$$CreateTransactionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      @JsonKey(name: 'amount_paisa') int amountPaisa,
      @JsonKey(name: 'from_bucket_id') String? fromBucketId,
      @JsonKey(name: 'to_bucket_id') String? toBucketId,
      @JsonKey(name: 'person_id') String? personId,
      String note,
      @JsonKey(name: 'occurred_at') DateTime occurredAt,
      @JsonKey(name: 'tag_ids') List<String> tagIds});
}

/// @nodoc
class __$$CreateTransactionRequestImplCopyWithImpl<$Res>
    extends _$CreateTransactionRequestCopyWithImpl<$Res,
        _$CreateTransactionRequestImpl>
    implements _$$CreateTransactionRequestImplCopyWith<$Res> {
  __$$CreateTransactionRequestImplCopyWithImpl(
      _$CreateTransactionRequestImpl _value,
      $Res Function(_$CreateTransactionRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateTransactionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? amountPaisa = null,
    Object? fromBucketId = freezed,
    Object? toBucketId = freezed,
    Object? personId = freezed,
    Object? note = null,
    Object? occurredAt = null,
    Object? tagIds = null,
  }) {
    return _then(_$CreateTransactionRequestImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: null == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int,
      fromBucketId: freezed == fromBucketId
          ? _value.fromBucketId
          : fromBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      toBucketId: freezed == toBucketId
          ? _value.toBucketId
          : toBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      personId: freezed == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String?,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tagIds: null == tagIds
          ? _value._tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTransactionRequestImpl implements _CreateTransactionRequest {
  const _$CreateTransactionRequestImpl(
      {required this.type,
      @JsonKey(name: 'amount_paisa') required this.amountPaisa,
      @JsonKey(name: 'from_bucket_id') this.fromBucketId,
      @JsonKey(name: 'to_bucket_id') this.toBucketId,
      @JsonKey(name: 'person_id') this.personId,
      this.note = '',
      @JsonKey(name: 'occurred_at') required this.occurredAt,
      @JsonKey(name: 'tag_ids') final List<String> tagIds = const []})
      : _tagIds = tagIds;

  factory _$CreateTransactionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTransactionRequestImplFromJson(json);

  @override
  final String type;
  @override
  @JsonKey(name: 'amount_paisa')
  final int amountPaisa;
  @override
  @JsonKey(name: 'from_bucket_id')
  final String? fromBucketId;
  @override
  @JsonKey(name: 'to_bucket_id')
  final String? toBucketId;
  @override
  @JsonKey(name: 'person_id')
  final String? personId;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey(name: 'occurred_at')
  final DateTime occurredAt;
  final List<String> _tagIds;
  @override
  @JsonKey(name: 'tag_ids')
  List<String> get tagIds {
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagIds);
  }

  @override
  String toString() {
    return 'CreateTransactionRequest(type: $type, amountPaisa: $amountPaisa, fromBucketId: $fromBucketId, toBucketId: $toBucketId, personId: $personId, note: $note, occurredAt: $occurredAt, tagIds: $tagIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTransactionRequestImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amountPaisa, amountPaisa) ||
                other.amountPaisa == amountPaisa) &&
            (identical(other.fromBucketId, fromBucketId) ||
                other.fromBucketId == fromBucketId) &&
            (identical(other.toBucketId, toBucketId) ||
                other.toBucketId == toBucketId) &&
            (identical(other.personId, personId) ||
                other.personId == personId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      amountPaisa,
      fromBucketId,
      toBucketId,
      personId,
      note,
      occurredAt,
      const DeepCollectionEquality().hash(_tagIds));

  /// Create a copy of CreateTransactionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTransactionRequestImplCopyWith<_$CreateTransactionRequestImpl>
      get copyWith => __$$CreateTransactionRequestImplCopyWithImpl<
          _$CreateTransactionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTransactionRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateTransactionRequest implements CreateTransactionRequest {
  const factory _CreateTransactionRequest(
          {required final String type,
          @JsonKey(name: 'amount_paisa') required final int amountPaisa,
          @JsonKey(name: 'from_bucket_id') final String? fromBucketId,
          @JsonKey(name: 'to_bucket_id') final String? toBucketId,
          @JsonKey(name: 'person_id') final String? personId,
          final String note,
          @JsonKey(name: 'occurred_at') required final DateTime occurredAt,
          @JsonKey(name: 'tag_ids') final List<String> tagIds}) =
      _$CreateTransactionRequestImpl;

  factory _CreateTransactionRequest.fromJson(Map<String, dynamic> json) =
      _$CreateTransactionRequestImpl.fromJson;

  @override
  String get type;
  @override
  @JsonKey(name: 'amount_paisa')
  int get amountPaisa;
  @override
  @JsonKey(name: 'from_bucket_id')
  String? get fromBucketId;
  @override
  @JsonKey(name: 'to_bucket_id')
  String? get toBucketId;
  @override
  @JsonKey(name: 'person_id')
  String? get personId;
  @override
  String get note;
  @override
  @JsonKey(name: 'occurred_at')
  DateTime get occurredAt;
  @override
  @JsonKey(name: 'tag_ids')
  List<String> get tagIds;

  /// Create a copy of CreateTransactionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTransactionRequestImplCopyWith<_$CreateTransactionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BucketBalance _$BucketBalanceFromJson(Map<String, dynamic> json) {
  return _BucketBalance.fromJson(json);
}

/// @nodoc
mixin _$BucketBalance {
  @JsonKey(name: 'bucket_id')
  String get bucketId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'balance_paisa')
  int get balancePaisa => throw _privateConstructorUsedError;

  /// Serializes this BucketBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BucketBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BucketBalanceCopyWith<BucketBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BucketBalanceCopyWith<$Res> {
  factory $BucketBalanceCopyWith(
          BucketBalance value, $Res Function(BucketBalance) then) =
      _$BucketBalanceCopyWithImpl<$Res, BucketBalance>;
  @useResult
  $Res call(
      {@JsonKey(name: 'bucket_id') String bucketId,
      String name,
      @JsonKey(name: 'balance_paisa') int balancePaisa});
}

/// @nodoc
class _$BucketBalanceCopyWithImpl<$Res, $Val extends BucketBalance>
    implements $BucketBalanceCopyWith<$Res> {
  _$BucketBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BucketBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bucketId = null,
    Object? name = null,
    Object? balancePaisa = null,
  }) {
    return _then(_value.copyWith(
      bucketId: null == bucketId
          ? _value.bucketId
          : bucketId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      balancePaisa: null == balancePaisa
          ? _value.balancePaisa
          : balancePaisa // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BucketBalanceImplCopyWith<$Res>
    implements $BucketBalanceCopyWith<$Res> {
  factory _$$BucketBalanceImplCopyWith(
          _$BucketBalanceImpl value, $Res Function(_$BucketBalanceImpl) then) =
      __$$BucketBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'bucket_id') String bucketId,
      String name,
      @JsonKey(name: 'balance_paisa') int balancePaisa});
}

/// @nodoc
class __$$BucketBalanceImplCopyWithImpl<$Res>
    extends _$BucketBalanceCopyWithImpl<$Res, _$BucketBalanceImpl>
    implements _$$BucketBalanceImplCopyWith<$Res> {
  __$$BucketBalanceImplCopyWithImpl(
      _$BucketBalanceImpl _value, $Res Function(_$BucketBalanceImpl) _then)
      : super(_value, _then);

  /// Create a copy of BucketBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bucketId = null,
    Object? name = null,
    Object? balancePaisa = null,
  }) {
    return _then(_$BucketBalanceImpl(
      bucketId: null == bucketId
          ? _value.bucketId
          : bucketId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      balancePaisa: null == balancePaisa
          ? _value.balancePaisa
          : balancePaisa // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BucketBalanceImpl implements _BucketBalance {
  const _$BucketBalanceImpl(
      {@JsonKey(name: 'bucket_id') required this.bucketId,
      required this.name,
      @JsonKey(name: 'balance_paisa') required this.balancePaisa});

  factory _$BucketBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$BucketBalanceImplFromJson(json);

  @override
  @JsonKey(name: 'bucket_id')
  final String bucketId;
  @override
  final String name;
  @override
  @JsonKey(name: 'balance_paisa')
  final int balancePaisa;

  @override
  String toString() {
    return 'BucketBalance(bucketId: $bucketId, name: $name, balancePaisa: $balancePaisa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BucketBalanceImpl &&
            (identical(other.bucketId, bucketId) ||
                other.bucketId == bucketId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.balancePaisa, balancePaisa) ||
                other.balancePaisa == balancePaisa));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bucketId, name, balancePaisa);

  /// Create a copy of BucketBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BucketBalanceImplCopyWith<_$BucketBalanceImpl> get copyWith =>
      __$$BucketBalanceImplCopyWithImpl<_$BucketBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BucketBalanceImplToJson(
      this,
    );
  }
}

abstract class _BucketBalance implements BucketBalance {
  const factory _BucketBalance(
          {@JsonKey(name: 'bucket_id') required final String bucketId,
          required final String name,
          @JsonKey(name: 'balance_paisa') required final int balancePaisa}) =
      _$BucketBalanceImpl;

  factory _BucketBalance.fromJson(Map<String, dynamic> json) =
      _$BucketBalanceImpl.fromJson;

  @override
  @JsonKey(name: 'bucket_id')
  String get bucketId;
  @override
  String get name;
  @override
  @JsonKey(name: 'balance_paisa')
  int get balancePaisa;

  /// Create a copy of BucketBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BucketBalanceImplCopyWith<_$BucketBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonBalance _$PersonBalanceFromJson(Map<String, dynamic> json) {
  return _PersonBalance.fromJson(json);
}

/// @nodoc
mixin _$PersonBalance {
  @JsonKey(name: 'person_id')
  String get personId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_paisa')
  int get netPaisa => throw _privateConstructorUsedError;

  /// Serializes this PersonBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PersonBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonBalanceCopyWith<PersonBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonBalanceCopyWith<$Res> {
  factory $PersonBalanceCopyWith(
          PersonBalance value, $Res Function(PersonBalance) then) =
      _$PersonBalanceCopyWithImpl<$Res, PersonBalance>;
  @useResult
  $Res call(
      {@JsonKey(name: 'person_id') String personId,
      String name,
      @JsonKey(name: 'net_paisa') int netPaisa});
}

/// @nodoc
class _$PersonBalanceCopyWithImpl<$Res, $Val extends PersonBalance>
    implements $PersonBalanceCopyWith<$Res> {
  _$PersonBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? personId = null,
    Object? name = null,
    Object? netPaisa = null,
  }) {
    return _then(_value.copyWith(
      personId: null == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      netPaisa: null == netPaisa
          ? _value.netPaisa
          : netPaisa // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonBalanceImplCopyWith<$Res>
    implements $PersonBalanceCopyWith<$Res> {
  factory _$$PersonBalanceImplCopyWith(
          _$PersonBalanceImpl value, $Res Function(_$PersonBalanceImpl) then) =
      __$$PersonBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'person_id') String personId,
      String name,
      @JsonKey(name: 'net_paisa') int netPaisa});
}

/// @nodoc
class __$$PersonBalanceImplCopyWithImpl<$Res>
    extends _$PersonBalanceCopyWithImpl<$Res, _$PersonBalanceImpl>
    implements _$$PersonBalanceImplCopyWith<$Res> {
  __$$PersonBalanceImplCopyWithImpl(
      _$PersonBalanceImpl _value, $Res Function(_$PersonBalanceImpl) _then)
      : super(_value, _then);

  /// Create a copy of PersonBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? personId = null,
    Object? name = null,
    Object? netPaisa = null,
  }) {
    return _then(_$PersonBalanceImpl(
      personId: null == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      netPaisa: null == netPaisa
          ? _value.netPaisa
          : netPaisa // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonBalanceImpl implements _PersonBalance {
  const _$PersonBalanceImpl(
      {@JsonKey(name: 'person_id') required this.personId,
      required this.name,
      @JsonKey(name: 'net_paisa') required this.netPaisa});

  factory _$PersonBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonBalanceImplFromJson(json);

  @override
  @JsonKey(name: 'person_id')
  final String personId;
  @override
  final String name;
  @override
  @JsonKey(name: 'net_paisa')
  final int netPaisa;

  @override
  String toString() {
    return 'PersonBalance(personId: $personId, name: $name, netPaisa: $netPaisa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonBalanceImpl &&
            (identical(other.personId, personId) ||
                other.personId == personId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.netPaisa, netPaisa) ||
                other.netPaisa == netPaisa));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, personId, name, netPaisa);

  /// Create a copy of PersonBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonBalanceImplCopyWith<_$PersonBalanceImpl> get copyWith =>
      __$$PersonBalanceImplCopyWithImpl<_$PersonBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonBalanceImplToJson(
      this,
    );
  }
}

abstract class _PersonBalance implements PersonBalance {
  const factory _PersonBalance(
          {@JsonKey(name: 'person_id') required final String personId,
          required final String name,
          @JsonKey(name: 'net_paisa') required final int netPaisa}) =
      _$PersonBalanceImpl;

  factory _PersonBalance.fromJson(Map<String, dynamic> json) =
      _$PersonBalanceImpl.fromJson;

  @override
  @JsonKey(name: 'person_id')
  String get personId;
  @override
  String get name;
  @override
  @JsonKey(name: 'net_paisa')
  int get netPaisa;

  /// Create a copy of PersonBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonBalanceImplCopyWith<_$PersonBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TagTotal _$TagTotalFromJson(Map<String, dynamic> json) {
  return _TagTotal.fromJson(json);
}

/// @nodoc
mixin _$TagTotal {
  @JsonKey(name: 'tag_id')
  String get tagId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_paisa')
  int get totalPaisa => throw _privateConstructorUsedError;

  /// Serializes this TagTotal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TagTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagTotalCopyWith<TagTotal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagTotalCopyWith<$Res> {
  factory $TagTotalCopyWith(TagTotal value, $Res Function(TagTotal) then) =
      _$TagTotalCopyWithImpl<$Res, TagTotal>;
  @useResult
  $Res call(
      {@JsonKey(name: 'tag_id') String tagId,
      String name,
      @JsonKey(name: 'total_paisa') int totalPaisa});
}

/// @nodoc
class _$TagTotalCopyWithImpl<$Res, $Val extends TagTotal>
    implements $TagTotalCopyWith<$Res> {
  _$TagTotalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TagTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagId = null,
    Object? name = null,
    Object? totalPaisa = null,
  }) {
    return _then(_value.copyWith(
      tagId: null == tagId
          ? _value.tagId
          : tagId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      totalPaisa: null == totalPaisa
          ? _value.totalPaisa
          : totalPaisa // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TagTotalImplCopyWith<$Res>
    implements $TagTotalCopyWith<$Res> {
  factory _$$TagTotalImplCopyWith(
          _$TagTotalImpl value, $Res Function(_$TagTotalImpl) then) =
      __$$TagTotalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'tag_id') String tagId,
      String name,
      @JsonKey(name: 'total_paisa') int totalPaisa});
}

/// @nodoc
class __$$TagTotalImplCopyWithImpl<$Res>
    extends _$TagTotalCopyWithImpl<$Res, _$TagTotalImpl>
    implements _$$TagTotalImplCopyWith<$Res> {
  __$$TagTotalImplCopyWithImpl(
      _$TagTotalImpl _value, $Res Function(_$TagTotalImpl) _then)
      : super(_value, _then);

  /// Create a copy of TagTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagId = null,
    Object? name = null,
    Object? totalPaisa = null,
  }) {
    return _then(_$TagTotalImpl(
      tagId: null == tagId
          ? _value.tagId
          : tagId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      totalPaisa: null == totalPaisa
          ? _value.totalPaisa
          : totalPaisa // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TagTotalImpl implements _TagTotal {
  const _$TagTotalImpl(
      {@JsonKey(name: 'tag_id') required this.tagId,
      required this.name,
      @JsonKey(name: 'total_paisa') required this.totalPaisa});

  factory _$TagTotalImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagTotalImplFromJson(json);

  @override
  @JsonKey(name: 'tag_id')
  final String tagId;
  @override
  final String name;
  @override
  @JsonKey(name: 'total_paisa')
  final int totalPaisa;

  @override
  String toString() {
    return 'TagTotal(tagId: $tagId, name: $name, totalPaisa: $totalPaisa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagTotalImpl &&
            (identical(other.tagId, tagId) || other.tagId == tagId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.totalPaisa, totalPaisa) ||
                other.totalPaisa == totalPaisa));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tagId, name, totalPaisa);

  /// Create a copy of TagTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagTotalImplCopyWith<_$TagTotalImpl> get copyWith =>
      __$$TagTotalImplCopyWithImpl<_$TagTotalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagTotalImplToJson(
      this,
    );
  }
}

abstract class _TagTotal implements TagTotal {
  const factory _TagTotal(
          {@JsonKey(name: 'tag_id') required final String tagId,
          required final String name,
          @JsonKey(name: 'total_paisa') required final int totalPaisa}) =
      _$TagTotalImpl;

  factory _TagTotal.fromJson(Map<String, dynamic> json) =
      _$TagTotalImpl.fromJson;

  @override
  @JsonKey(name: 'tag_id')
  String get tagId;
  @override
  String get name;
  @override
  @JsonKey(name: 'total_paisa')
  int get totalPaisa;

  /// Create a copy of TagTotal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagTotalImplCopyWith<_$TagTotalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthlySummary _$MonthlySummaryFromJson(Map<String, dynamic> json) {
  return _MonthlySummary.fromJson(json);
}

/// @nodoc
mixin _$MonthlySummary {
  @JsonKey(name: 'income_paisa')
  int get incomePaisa => throw _privateConstructorUsedError;
  @JsonKey(name: 'expense_paisa')
  int get expensePaisa => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_paisa')
  int get netPaisa => throw _privateConstructorUsedError;
  @JsonKey(name: 'by_tag')
  List<TagTotal> get byTag => throw _privateConstructorUsedError;

  /// Serializes this MonthlySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlySummaryCopyWith<MonthlySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlySummaryCopyWith<$Res> {
  factory $MonthlySummaryCopyWith(
          MonthlySummary value, $Res Function(MonthlySummary) then) =
      _$MonthlySummaryCopyWithImpl<$Res, MonthlySummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'income_paisa') int incomePaisa,
      @JsonKey(name: 'expense_paisa') int expensePaisa,
      @JsonKey(name: 'net_paisa') int netPaisa,
      @JsonKey(name: 'by_tag') List<TagTotal> byTag});
}

/// @nodoc
class _$MonthlySummaryCopyWithImpl<$Res, $Val extends MonthlySummary>
    implements $MonthlySummaryCopyWith<$Res> {
  _$MonthlySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? incomePaisa = null,
    Object? expensePaisa = null,
    Object? netPaisa = null,
    Object? byTag = null,
  }) {
    return _then(_value.copyWith(
      incomePaisa: null == incomePaisa
          ? _value.incomePaisa
          : incomePaisa // ignore: cast_nullable_to_non_nullable
              as int,
      expensePaisa: null == expensePaisa
          ? _value.expensePaisa
          : expensePaisa // ignore: cast_nullable_to_non_nullable
              as int,
      netPaisa: null == netPaisa
          ? _value.netPaisa
          : netPaisa // ignore: cast_nullable_to_non_nullable
              as int,
      byTag: null == byTag
          ? _value.byTag
          : byTag // ignore: cast_nullable_to_non_nullable
              as List<TagTotal>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlySummaryImplCopyWith<$Res>
    implements $MonthlySummaryCopyWith<$Res> {
  factory _$$MonthlySummaryImplCopyWith(_$MonthlySummaryImpl value,
          $Res Function(_$MonthlySummaryImpl) then) =
      __$$MonthlySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'income_paisa') int incomePaisa,
      @JsonKey(name: 'expense_paisa') int expensePaisa,
      @JsonKey(name: 'net_paisa') int netPaisa,
      @JsonKey(name: 'by_tag') List<TagTotal> byTag});
}

/// @nodoc
class __$$MonthlySummaryImplCopyWithImpl<$Res>
    extends _$MonthlySummaryCopyWithImpl<$Res, _$MonthlySummaryImpl>
    implements _$$MonthlySummaryImplCopyWith<$Res> {
  __$$MonthlySummaryImplCopyWithImpl(
      _$MonthlySummaryImpl _value, $Res Function(_$MonthlySummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? incomePaisa = null,
    Object? expensePaisa = null,
    Object? netPaisa = null,
    Object? byTag = null,
  }) {
    return _then(_$MonthlySummaryImpl(
      incomePaisa: null == incomePaisa
          ? _value.incomePaisa
          : incomePaisa // ignore: cast_nullable_to_non_nullable
              as int,
      expensePaisa: null == expensePaisa
          ? _value.expensePaisa
          : expensePaisa // ignore: cast_nullable_to_non_nullable
              as int,
      netPaisa: null == netPaisa
          ? _value.netPaisa
          : netPaisa // ignore: cast_nullable_to_non_nullable
              as int,
      byTag: null == byTag
          ? _value._byTag
          : byTag // ignore: cast_nullable_to_non_nullable
              as List<TagTotal>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlySummaryImpl implements _MonthlySummary {
  const _$MonthlySummaryImpl(
      {@JsonKey(name: 'income_paisa') required this.incomePaisa,
      @JsonKey(name: 'expense_paisa') required this.expensePaisa,
      @JsonKey(name: 'net_paisa') required this.netPaisa,
      @JsonKey(name: 'by_tag') required final List<TagTotal> byTag})
      : _byTag = byTag;

  factory _$MonthlySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlySummaryImplFromJson(json);

  @override
  @JsonKey(name: 'income_paisa')
  final int incomePaisa;
  @override
  @JsonKey(name: 'expense_paisa')
  final int expensePaisa;
  @override
  @JsonKey(name: 'net_paisa')
  final int netPaisa;
  final List<TagTotal> _byTag;
  @override
  @JsonKey(name: 'by_tag')
  List<TagTotal> get byTag {
    if (_byTag is EqualUnmodifiableListView) return _byTag;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_byTag);
  }

  @override
  String toString() {
    return 'MonthlySummary(incomePaisa: $incomePaisa, expensePaisa: $expensePaisa, netPaisa: $netPaisa, byTag: $byTag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlySummaryImpl &&
            (identical(other.incomePaisa, incomePaisa) ||
                other.incomePaisa == incomePaisa) &&
            (identical(other.expensePaisa, expensePaisa) ||
                other.expensePaisa == expensePaisa) &&
            (identical(other.netPaisa, netPaisa) ||
                other.netPaisa == netPaisa) &&
            const DeepCollectionEquality().equals(other._byTag, _byTag));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, incomePaisa, expensePaisa,
      netPaisa, const DeepCollectionEquality().hash(_byTag));

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      __$$MonthlySummaryImplCopyWithImpl<_$MonthlySummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlySummaryImplToJson(
      this,
    );
  }
}

abstract class _MonthlySummary implements MonthlySummary {
  const factory _MonthlySummary(
          {@JsonKey(name: 'income_paisa') required final int incomePaisa,
          @JsonKey(name: 'expense_paisa') required final int expensePaisa,
          @JsonKey(name: 'net_paisa') required final int netPaisa,
          @JsonKey(name: 'by_tag') required final List<TagTotal> byTag}) =
      _$MonthlySummaryImpl;

  factory _MonthlySummary.fromJson(Map<String, dynamic> json) =
      _$MonthlySummaryImpl.fromJson;

  @override
  @JsonKey(name: 'income_paisa')
  int get incomePaisa;
  @override
  @JsonKey(name: 'expense_paisa')
  int get expensePaisa;
  @override
  @JsonKey(name: 'net_paisa')
  int get netPaisa;
  @override
  @JsonKey(name: 'by_tag')
  List<TagTotal> get byTag;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Reminder _$ReminderFromJson(Map<String, dynamic> json) {
  return _Reminder.fromJson(json);
}

/// @nodoc
mixin _$Reminder {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paisa')
  int? get amountPaisa => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_type')
  String get defaultType => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_type')
  String get recurrenceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_day')
  int? get recurrenceDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_due_at')
  DateTime get nextDueAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'linked_bucket_id')
  String? get linkedBucketId => throw _privateConstructorUsedError;
  @JsonKey(name: 'linked_person_id')
  String? get linkedPersonId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReminderCopyWith<Reminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReminderCopyWith<$Res> {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) then) =
      _$ReminderCopyWithImpl<$Res, Reminder>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String title,
      @JsonKey(name: 'amount_paisa') int? amountPaisa,
      @JsonKey(name: 'default_type') String defaultType,
      @JsonKey(name: 'recurrence_type') String recurrenceType,
      @JsonKey(name: 'recurrence_day') int? recurrenceDay,
      @JsonKey(name: 'next_due_at') DateTime nextDueAt,
      @JsonKey(name: 'linked_bucket_id') String? linkedBucketId,
      @JsonKey(name: 'linked_person_id') String? linkedPersonId,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$ReminderCopyWithImpl<$Res, $Val extends Reminder>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? amountPaisa = freezed,
    Object? defaultType = null,
    Object? recurrenceType = null,
    Object? recurrenceDay = freezed,
    Object? nextDueAt = null,
    Object? linkedBucketId = freezed,
    Object? linkedPersonId = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: freezed == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultType: null == defaultType
          ? _value.defaultType
          : defaultType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceType: null == recurrenceType
          ? _value.recurrenceType
          : recurrenceType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceDay: freezed == recurrenceDay
          ? _value.recurrenceDay
          : recurrenceDay // ignore: cast_nullable_to_non_nullable
              as int?,
      nextDueAt: null == nextDueAt
          ? _value.nextDueAt
          : nextDueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      linkedBucketId: freezed == linkedBucketId
          ? _value.linkedBucketId
          : linkedBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedPersonId: freezed == linkedPersonId
          ? _value.linkedPersonId
          : linkedPersonId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReminderImplCopyWith<$Res>
    implements $ReminderCopyWith<$Res> {
  factory _$$ReminderImplCopyWith(
          _$ReminderImpl value, $Res Function(_$ReminderImpl) then) =
      __$$ReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String title,
      @JsonKey(name: 'amount_paisa') int? amountPaisa,
      @JsonKey(name: 'default_type') String defaultType,
      @JsonKey(name: 'recurrence_type') String recurrenceType,
      @JsonKey(name: 'recurrence_day') int? recurrenceDay,
      @JsonKey(name: 'next_due_at') DateTime nextDueAt,
      @JsonKey(name: 'linked_bucket_id') String? linkedBucketId,
      @JsonKey(name: 'linked_person_id') String? linkedPersonId,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$ReminderImplCopyWithImpl<$Res>
    extends _$ReminderCopyWithImpl<$Res, _$ReminderImpl>
    implements _$$ReminderImplCopyWith<$Res> {
  __$$ReminderImplCopyWithImpl(
      _$ReminderImpl _value, $Res Function(_$ReminderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? amountPaisa = freezed,
    Object? defaultType = null,
    Object? recurrenceType = null,
    Object? recurrenceDay = freezed,
    Object? nextDueAt = null,
    Object? linkedBucketId = freezed,
    Object? linkedPersonId = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_$ReminderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: freezed == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultType: null == defaultType
          ? _value.defaultType
          : defaultType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceType: null == recurrenceType
          ? _value.recurrenceType
          : recurrenceType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceDay: freezed == recurrenceDay
          ? _value.recurrenceDay
          : recurrenceDay // ignore: cast_nullable_to_non_nullable
              as int?,
      nextDueAt: null == nextDueAt
          ? _value.nextDueAt
          : nextDueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      linkedBucketId: freezed == linkedBucketId
          ? _value.linkedBucketId
          : linkedBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedPersonId: freezed == linkedPersonId
          ? _value.linkedPersonId
          : linkedPersonId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReminderImpl implements _Reminder {
  const _$ReminderImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.title,
      @JsonKey(name: 'amount_paisa') this.amountPaisa,
      @JsonKey(name: 'default_type') required this.defaultType,
      @JsonKey(name: 'recurrence_type') required this.recurrenceType,
      @JsonKey(name: 'recurrence_day') this.recurrenceDay,
      @JsonKey(name: 'next_due_at') required this.nextDueAt,
      @JsonKey(name: 'linked_bucket_id') this.linkedBucketId,
      @JsonKey(name: 'linked_person_id') this.linkedPersonId,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$ReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReminderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String title;
  @override
  @JsonKey(name: 'amount_paisa')
  final int? amountPaisa;
  @override
  @JsonKey(name: 'default_type')
  final String defaultType;
  @override
  @JsonKey(name: 'recurrence_type')
  final String recurrenceType;
  @override
  @JsonKey(name: 'recurrence_day')
  final int? recurrenceDay;
  @override
  @JsonKey(name: 'next_due_at')
  final DateTime nextDueAt;
  @override
  @JsonKey(name: 'linked_bucket_id')
  final String? linkedBucketId;
  @override
  @JsonKey(name: 'linked_person_id')
  final String? linkedPersonId;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Reminder(id: $id, userId: $userId, title: $title, amountPaisa: $amountPaisa, defaultType: $defaultType, recurrenceType: $recurrenceType, recurrenceDay: $recurrenceDay, nextDueAt: $nextDueAt, linkedBucketId: $linkedBucketId, linkedPersonId: $linkedPersonId, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amountPaisa, amountPaisa) ||
                other.amountPaisa == amountPaisa) &&
            (identical(other.defaultType, defaultType) ||
                other.defaultType == defaultType) &&
            (identical(other.recurrenceType, recurrenceType) ||
                other.recurrenceType == recurrenceType) &&
            (identical(other.recurrenceDay, recurrenceDay) ||
                other.recurrenceDay == recurrenceDay) &&
            (identical(other.nextDueAt, nextDueAt) ||
                other.nextDueAt == nextDueAt) &&
            (identical(other.linkedBucketId, linkedBucketId) ||
                other.linkedBucketId == linkedBucketId) &&
            (identical(other.linkedPersonId, linkedPersonId) ||
                other.linkedPersonId == linkedPersonId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      amountPaisa,
      defaultType,
      recurrenceType,
      recurrenceDay,
      nextDueAt,
      linkedBucketId,
      linkedPersonId,
      status,
      createdAt);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      __$$ReminderImplCopyWithImpl<_$ReminderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReminderImplToJson(
      this,
    );
  }
}

abstract class _Reminder implements Reminder {
  const factory _Reminder(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      required final String title,
      @JsonKey(name: 'amount_paisa') final int? amountPaisa,
      @JsonKey(name: 'default_type') required final String defaultType,
      @JsonKey(name: 'recurrence_type') required final String recurrenceType,
      @JsonKey(name: 'recurrence_day') final int? recurrenceDay,
      @JsonKey(name: 'next_due_at') required final DateTime nextDueAt,
      @JsonKey(name: 'linked_bucket_id') final String? linkedBucketId,
      @JsonKey(name: 'linked_person_id') final String? linkedPersonId,
      required final String status,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$ReminderImpl;

  factory _Reminder.fromJson(Map<String, dynamic> json) =
      _$ReminderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get title;
  @override
  @JsonKey(name: 'amount_paisa')
  int? get amountPaisa;
  @override
  @JsonKey(name: 'default_type')
  String get defaultType;
  @override
  @JsonKey(name: 'recurrence_type')
  String get recurrenceType;
  @override
  @JsonKey(name: 'recurrence_day')
  int? get recurrenceDay;
  @override
  @JsonKey(name: 'next_due_at')
  DateTime get nextDueAt;
  @override
  @JsonKey(name: 'linked_bucket_id')
  String? get linkedBucketId;
  @override
  @JsonKey(name: 'linked_person_id')
  String? get linkedPersonId;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateReminderRequest _$CreateReminderRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateReminderRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateReminderRequest {
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paisa')
  int? get amountPaisa => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_type')
  String get defaultType => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_type')
  String get recurrenceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_day')
  int? get recurrenceDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_due_at')
  DateTime get nextDueAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'linked_bucket_id')
  String? get linkedBucketId => throw _privateConstructorUsedError;
  @JsonKey(name: 'linked_person_id')
  String? get linkedPersonId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tag_ids')
  List<String> get tagIds => throw _privateConstructorUsedError;

  /// Serializes this CreateReminderRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateReminderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateReminderRequestCopyWith<CreateReminderRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateReminderRequestCopyWith<$Res> {
  factory $CreateReminderRequestCopyWith(CreateReminderRequest value,
          $Res Function(CreateReminderRequest) then) =
      _$CreateReminderRequestCopyWithImpl<$Res, CreateReminderRequest>;
  @useResult
  $Res call(
      {String title,
      @JsonKey(name: 'amount_paisa') int? amountPaisa,
      @JsonKey(name: 'default_type') String defaultType,
      @JsonKey(name: 'recurrence_type') String recurrenceType,
      @JsonKey(name: 'recurrence_day') int? recurrenceDay,
      @JsonKey(name: 'next_due_at') DateTime nextDueAt,
      @JsonKey(name: 'linked_bucket_id') String? linkedBucketId,
      @JsonKey(name: 'linked_person_id') String? linkedPersonId,
      @JsonKey(name: 'tag_ids') List<String> tagIds});
}

/// @nodoc
class _$CreateReminderRequestCopyWithImpl<$Res,
        $Val extends CreateReminderRequest>
    implements $CreateReminderRequestCopyWith<$Res> {
  _$CreateReminderRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateReminderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? amountPaisa = freezed,
    Object? defaultType = null,
    Object? recurrenceType = null,
    Object? recurrenceDay = freezed,
    Object? nextDueAt = null,
    Object? linkedBucketId = freezed,
    Object? linkedPersonId = freezed,
    Object? tagIds = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: freezed == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultType: null == defaultType
          ? _value.defaultType
          : defaultType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceType: null == recurrenceType
          ? _value.recurrenceType
          : recurrenceType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceDay: freezed == recurrenceDay
          ? _value.recurrenceDay
          : recurrenceDay // ignore: cast_nullable_to_non_nullable
              as int?,
      nextDueAt: null == nextDueAt
          ? _value.nextDueAt
          : nextDueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      linkedBucketId: freezed == linkedBucketId
          ? _value.linkedBucketId
          : linkedBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedPersonId: freezed == linkedPersonId
          ? _value.linkedPersonId
          : linkedPersonId // ignore: cast_nullable_to_non_nullable
              as String?,
      tagIds: null == tagIds
          ? _value.tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateReminderRequestImplCopyWith<$Res>
    implements $CreateReminderRequestCopyWith<$Res> {
  factory _$$CreateReminderRequestImplCopyWith(
          _$CreateReminderRequestImpl value,
          $Res Function(_$CreateReminderRequestImpl) then) =
      __$$CreateReminderRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      @JsonKey(name: 'amount_paisa') int? amountPaisa,
      @JsonKey(name: 'default_type') String defaultType,
      @JsonKey(name: 'recurrence_type') String recurrenceType,
      @JsonKey(name: 'recurrence_day') int? recurrenceDay,
      @JsonKey(name: 'next_due_at') DateTime nextDueAt,
      @JsonKey(name: 'linked_bucket_id') String? linkedBucketId,
      @JsonKey(name: 'linked_person_id') String? linkedPersonId,
      @JsonKey(name: 'tag_ids') List<String> tagIds});
}

/// @nodoc
class __$$CreateReminderRequestImplCopyWithImpl<$Res>
    extends _$CreateReminderRequestCopyWithImpl<$Res,
        _$CreateReminderRequestImpl>
    implements _$$CreateReminderRequestImplCopyWith<$Res> {
  __$$CreateReminderRequestImplCopyWithImpl(_$CreateReminderRequestImpl _value,
      $Res Function(_$CreateReminderRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateReminderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? amountPaisa = freezed,
    Object? defaultType = null,
    Object? recurrenceType = null,
    Object? recurrenceDay = freezed,
    Object? nextDueAt = null,
    Object? linkedBucketId = freezed,
    Object? linkedPersonId = freezed,
    Object? tagIds = null,
  }) {
    return _then(_$CreateReminderRequestImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaisa: freezed == amountPaisa
          ? _value.amountPaisa
          : amountPaisa // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultType: null == defaultType
          ? _value.defaultType
          : defaultType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceType: null == recurrenceType
          ? _value.recurrenceType
          : recurrenceType // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceDay: freezed == recurrenceDay
          ? _value.recurrenceDay
          : recurrenceDay // ignore: cast_nullable_to_non_nullable
              as int?,
      nextDueAt: null == nextDueAt
          ? _value.nextDueAt
          : nextDueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      linkedBucketId: freezed == linkedBucketId
          ? _value.linkedBucketId
          : linkedBucketId // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedPersonId: freezed == linkedPersonId
          ? _value.linkedPersonId
          : linkedPersonId // ignore: cast_nullable_to_non_nullable
              as String?,
      tagIds: null == tagIds
          ? _value._tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateReminderRequestImpl implements _CreateReminderRequest {
  const _$CreateReminderRequestImpl(
      {required this.title,
      @JsonKey(name: 'amount_paisa') this.amountPaisa,
      @JsonKey(name: 'default_type') required this.defaultType,
      @JsonKey(name: 'recurrence_type') required this.recurrenceType,
      @JsonKey(name: 'recurrence_day') this.recurrenceDay,
      @JsonKey(name: 'next_due_at') required this.nextDueAt,
      @JsonKey(name: 'linked_bucket_id') this.linkedBucketId,
      @JsonKey(name: 'linked_person_id') this.linkedPersonId,
      @JsonKey(name: 'tag_ids') final List<String> tagIds = const []})
      : _tagIds = tagIds;

  factory _$CreateReminderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateReminderRequestImplFromJson(json);

  @override
  final String title;
  @override
  @JsonKey(name: 'amount_paisa')
  final int? amountPaisa;
  @override
  @JsonKey(name: 'default_type')
  final String defaultType;
  @override
  @JsonKey(name: 'recurrence_type')
  final String recurrenceType;
  @override
  @JsonKey(name: 'recurrence_day')
  final int? recurrenceDay;
  @override
  @JsonKey(name: 'next_due_at')
  final DateTime nextDueAt;
  @override
  @JsonKey(name: 'linked_bucket_id')
  final String? linkedBucketId;
  @override
  @JsonKey(name: 'linked_person_id')
  final String? linkedPersonId;
  final List<String> _tagIds;
  @override
  @JsonKey(name: 'tag_ids')
  List<String> get tagIds {
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagIds);
  }

  @override
  String toString() {
    return 'CreateReminderRequest(title: $title, amountPaisa: $amountPaisa, defaultType: $defaultType, recurrenceType: $recurrenceType, recurrenceDay: $recurrenceDay, nextDueAt: $nextDueAt, linkedBucketId: $linkedBucketId, linkedPersonId: $linkedPersonId, tagIds: $tagIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateReminderRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amountPaisa, amountPaisa) ||
                other.amountPaisa == amountPaisa) &&
            (identical(other.defaultType, defaultType) ||
                other.defaultType == defaultType) &&
            (identical(other.recurrenceType, recurrenceType) ||
                other.recurrenceType == recurrenceType) &&
            (identical(other.recurrenceDay, recurrenceDay) ||
                other.recurrenceDay == recurrenceDay) &&
            (identical(other.nextDueAt, nextDueAt) ||
                other.nextDueAt == nextDueAt) &&
            (identical(other.linkedBucketId, linkedBucketId) ||
                other.linkedBucketId == linkedBucketId) &&
            (identical(other.linkedPersonId, linkedPersonId) ||
                other.linkedPersonId == linkedPersonId) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      amountPaisa,
      defaultType,
      recurrenceType,
      recurrenceDay,
      nextDueAt,
      linkedBucketId,
      linkedPersonId,
      const DeepCollectionEquality().hash(_tagIds));

  /// Create a copy of CreateReminderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateReminderRequestImplCopyWith<_$CreateReminderRequestImpl>
      get copyWith => __$$CreateReminderRequestImplCopyWithImpl<
          _$CreateReminderRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateReminderRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateReminderRequest implements CreateReminderRequest {
  const factory _CreateReminderRequest(
      {required final String title,
      @JsonKey(name: 'amount_paisa') final int? amountPaisa,
      @JsonKey(name: 'default_type') required final String defaultType,
      @JsonKey(name: 'recurrence_type') required final String recurrenceType,
      @JsonKey(name: 'recurrence_day') final int? recurrenceDay,
      @JsonKey(name: 'next_due_at') required final DateTime nextDueAt,
      @JsonKey(name: 'linked_bucket_id') final String? linkedBucketId,
      @JsonKey(name: 'linked_person_id') final String? linkedPersonId,
      @JsonKey(name: 'tag_ids')
      final List<String> tagIds}) = _$CreateReminderRequestImpl;

  factory _CreateReminderRequest.fromJson(Map<String, dynamic> json) =
      _$CreateReminderRequestImpl.fromJson;

  @override
  String get title;
  @override
  @JsonKey(name: 'amount_paisa')
  int? get amountPaisa;
  @override
  @JsonKey(name: 'default_type')
  String get defaultType;
  @override
  @JsonKey(name: 'recurrence_type')
  String get recurrenceType;
  @override
  @JsonKey(name: 'recurrence_day')
  int? get recurrenceDay;
  @override
  @JsonKey(name: 'next_due_at')
  DateTime get nextDueAt;
  @override
  @JsonKey(name: 'linked_bucket_id')
  String? get linkedBucketId;
  @override
  @JsonKey(name: 'linked_person_id')
  String? get linkedPersonId;
  @override
  @JsonKey(name: 'tag_ids')
  List<String> get tagIds;

  /// Create a copy of CreateReminderRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateReminderRequestImplCopyWith<_$CreateReminderRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
