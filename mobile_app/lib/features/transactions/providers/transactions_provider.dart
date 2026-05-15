import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionApiProvider = Provider((ref) => TransactionApi(ref.read(apiClientProvider)));

class TransactionApi {
  final Dio _dio;
  TransactionApi(this._dio);

  Future<Map<String, dynamic>> getTransactions({
    String? cursor,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('transactions', queryParameters: {
      'limit': limit,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ...?filters,
    });
    return response.data!;
  }

  Future<Transaction> createTransaction(CreateTransactionRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>('transactions', data: request.toJson());
    return Transaction.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<Transaction> updateTransaction(String id, CreateTransactionRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>('transactions/$id', data: request.toJson());
    return Transaction.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete<void>('transactions/$id');
  }
}

class TransactionState {
  final List<Transaction> items;
  final String? nextCursor;
  final bool isLoadingMore;

  const TransactionState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });
}

final transactionsProvider = AsyncNotifierProvider<TransactionsController, TransactionState>(() {
  return TransactionsController();
});

class TransactionsController extends AsyncNotifier<TransactionState> {
  Map<String, dynamic>? _filters;

  @override
  Future<TransactionState> build() async {
    final data = await ref.read(transactionApiProvider).getTransactions(filters: _filters);
    return TransactionState(
      items: (data['items'] as List).map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList(),
      nextCursor: data['next_cursor'] as String?,
    );
  }

  void applyFilters(Map<String, dynamic> filters) {
    _filters = filters.isEmpty ? null : filters;
    ref.invalidateSelf();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        current.nextCursor == null ||
        current.nextCursor!.isEmpty ||
        current.isLoadingMore) return;

    state = AsyncValue.data(TransactionState(
      items: current.items,
      nextCursor: current.nextCursor,
      isLoadingMore: true,
    ));

    try {
      final data = await ref.read(transactionApiProvider).getTransactions(
        cursor: current.nextCursor,
        filters: _filters,
      );
      state = AsyncValue.data(TransactionState(
        items: [
          ...current.items,
          ...(data['items'] as List).map((e) => Transaction.fromJson(e as Map<String, dynamic>)),
        ],
        nextCursor: data['next_cursor'] as String?,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> create(CreateTransactionRequest request) async {
    await ref.read(transactionApiProvider).createTransaction(request);
    ref.invalidateSelf();
  }

  Future<void> editTransaction(String id, CreateTransactionRequest request) async {
    await ref.read(transactionApiProvider).updateTransaction(id, request);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(transactionApiProvider).deleteTransaction(id);
    ref.invalidateSelf();
  }
}
