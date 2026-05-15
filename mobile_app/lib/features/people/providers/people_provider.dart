import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final peopleApiProvider = Provider((ref) => PeopleApi(ref.read(apiClientProvider)));

class PeopleApi {
  final Dio _dio;
  PeopleApi(this._dio);

  Future<List<Person>> getPeople() async {
    final response = await _dio.get<Map<String, dynamic>>('people');
    return (response.data!['items'] as List).map((e) => Person.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Person> createPerson(String name) async {
    final response = await _dio.post<Map<String, dynamic>>('people', data: {'name': name});
    return Person.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<Person> updatePerson(String id, {String? name, bool? archived}) async {
    final response = await _dio.patch<Map<String, dynamic>>('people/$id', data: {
      if (name != null) 'name': name,
      if (archived != null) 'archived': archived,
    });
    return Person.fromJson(response.data! as Map<String, dynamic>);
  }
}

final peopleProvider = AsyncNotifierProvider<PeopleController, List<Person>>(() {
  return PeopleController();
});

class PeopleController extends AsyncNotifier<List<Person>> {
  @override
  Future<List<Person>> build() async {
    return ref.read(peopleApiProvider).getPeople();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(peopleApiProvider).getPeople());
  }

  Future<void> create(String name) async {
    await ref.read(peopleApiProvider).createPerson(name);
    await refresh();
  }

  Future<void> editPerson(String id, {String? name, bool? archived}) async {
    await ref.read(peopleApiProvider).updatePerson(id, name: name, archived: archived);
    await refresh();
  }
}
