import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/features/transactions/providers/transactions_provider.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reminderApiProvider = Provider((ref) => ReminderApi(ref.read(apiClientProvider)));

class ReminderApi {
  final Dio _dio;
  ReminderApi(this._dio);

  Future<List<Reminder>> getReminders() async {
    final response = await _dio.get<Map<String, dynamic>>('reminders');
    return (response.data!['items'] as List).map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Reminder> createReminder(CreateReminderRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>('reminders', data: request.toJson());
    return Reminder.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<Reminder> updateReminder(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch<Map<String, dynamic>>('reminders/$id', data: data);
    return Reminder.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<void> payReminder(String id, {int? amountPaisa, DateTime? occurredAt, String? note}) async {
    await _dio.post<Map<String, dynamic>>('reminders/$id/pay', data: {
      if (amountPaisa != null) 'amount_paisa': amountPaisa,
      if (occurredAt != null) 'occurred_at': occurredAt.toUtc().toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  Future<Reminder> skipReminder(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('reminders/$id/skip', data: {});
    return Reminder.fromJson(response.data! as Map<String, dynamic>);
  }
}

final remindersProvider = AsyncNotifierProvider<RemindersController, List<Reminder>>(() {
  return RemindersController();
});

class RemindersController extends AsyncNotifier<List<Reminder>> {
  @override
  Future<List<Reminder>> build() async {
    return ref.read(reminderApiProvider).getReminders();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(reminderApiProvider).getReminders());
  }

  Future<void> create(CreateReminderRequest request) async {
    await ref.read(reminderApiProvider).createReminder(request);
    await refresh();
  }

  Future<void> editReminder(String id, Map<String, dynamic> data) async {
    await ref.read(reminderApiProvider).updateReminder(id, data);
    await refresh();
  }

  Future<void> pay(String id, {int? amountPaisa, DateTime? occurredAt, String? note}) async {
    await ref.read(reminderApiProvider).payReminder(
      id,
      amountPaisa: amountPaisa,
      occurredAt: occurredAt,
      note: note,
    );
    ref.invalidateSelf();
    ref.invalidate(transactionsProvider);
  }

  Future<void> skip(String id) async {
    await ref.read(reminderApiProvider).skipReminder(id);
    await refresh();
  }
}
