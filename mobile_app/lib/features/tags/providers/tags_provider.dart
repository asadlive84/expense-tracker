import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagsApiProvider = Provider((ref) => TagsApi(ref.read(apiClientProvider)));

class TagsApi {
  final Dio _dio;
  TagsApi(this._dio);

  Future<List<Tag>> getTags() async {
    final response = await _dio.get<Map<String, dynamic>>('tags');
    return (response.data!['items'] as List).map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Tag> createTag(String name) async {
    final response = await _dio.post<Map<String, dynamic>>('tags', data: {'name': name});
    return Tag.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<Tag> updateTag(String id, {String? name, bool? archived}) async {
    final response = await _dio.patch<Map<String, dynamic>>('tags/$id', data: {
      if (name != null) 'name': name,
      if (archived != null) 'archived': archived,
    });
    return Tag.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<void> deleteTag(String id) async {
    await _dio.delete<void>('tags/$id');
  }
}

final tagsProvider = AsyncNotifierProvider<TagsController, List<Tag>>(() {
  return TagsController();
});

class TagsController extends AsyncNotifier<List<Tag>> {
  @override
  Future<List<Tag>> build() async {
    return ref.read(tagsApiProvider).getTags();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(tagsApiProvider).getTags());
  }

  Future<void> create(String name) async {
    await ref.read(tagsApiProvider).createTag(name);
    await refresh();
  }

  Future<void> editTag(String id, {String? name, bool? archived}) async {
    await ref.read(tagsApiProvider).updateTag(id, name: name, archived: archived);
    await refresh();
  }

  /// Permanently deletes the tag. Linked transactions remain (junction rows
  /// are cascade-removed by the DB, transactions themselves are untouched).
  Future<void> deleteTag(String id) async {
    await ref.read(tagsApiProvider).deleteTag(id);
    await refresh();
  }
}
