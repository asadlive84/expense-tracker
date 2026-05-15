import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bucketApiProvider = Provider((ref) => BucketApi(ref.read(apiClientProvider)));

class BucketApi {
  final Dio _dio;
  BucketApi(this._dio);

  Future<List<Bucket>> getBuckets() async {
    final response = await _dio.get<Map<String, dynamic>>('buckets');
    return (response.data!['items'] as List).map((e) => Bucket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Bucket> createBucket(String name, int startingBalancePaisa) async {
    final response = await _dio.post<Map<String, dynamic>>('buckets', data: {
      'name': name,
      'starting_balance_paisa': startingBalancePaisa,
    });
    return Bucket.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<Bucket> updateBucket(String id, {String? name, bool? archived}) async {
    final response = await _dio.patch<Map<String, dynamic>>('buckets/$id', data: {
      if (name != null) 'name': name,
      if (archived != null) 'archived': archived,
    });
    return Bucket.fromJson(response.data! as Map<String, dynamic>);
  }
}

final bucketsProvider = AsyncNotifierProvider<BucketsController, List<Bucket>>(() {
  return BucketsController();
});

class BucketsController extends AsyncNotifier<List<Bucket>> {
  @override
  Future<List<Bucket>> build() async {
    return ref.read(bucketApiProvider).getBuckets();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(bucketApiProvider).getBuckets());
  }

  Future<void> create(String name, int startingBalancePaisa) async {
    await ref.read(bucketApiProvider).createBucket(name, startingBalancePaisa);
    await refresh();
  }

  Future<void> editBucket(String id, {String? name, bool? archived}) async {
    await ref.read(bucketApiProvider).updateBucket(id, name: name, archived: archived);
    await refresh();
  }
}
