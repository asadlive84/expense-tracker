import 'package:dio/dio.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsApiProvider = Provider((ref) => ReportsApi(ref.read(apiClientProvider)));

class ReportsApi {
  final Dio _dio;
  ReportsApi(this._dio);

  Future<List<BucketBalance>> getBucketBalances() async {
    final response = await _dio.get<Map<String, dynamic>>('reports/bucket-balances');
    return (response.data!['items'] as List).map((e) => BucketBalance.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PersonBalance>> getPersonBalances() async {
    final response = await _dio.get<Map<String, dynamic>>('reports/person-balances');
    return (response.data!['items'] as List).map((e) => PersonBalance.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TagTotal>> getTagTotals({required String from, required String to}) async {
    final response = await _dio.get<Map<String, dynamic>>('reports/tag-totals', queryParameters: {'from': from, 'to': to});
    return (response.data!['items'] as List).map((e) => TagTotal.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MonthlySummary> getMonthlySummary(String? month) async {
    final response = await _dio.get<Map<String, dynamic>>('reports/summary', queryParameters: {
      if (month != null) 'month': month,
    });
    return MonthlySummary.fromJson(response.data! as Map<String, dynamic>);
  }

  Future<MonthlySummary> getDateRangeSummary(String from, String to) async {
    final response = await _dio.get<Map<String, dynamic>>('reports/summary',
        queryParameters: {'from': from, 'to': to});
    return MonthlySummary.fromJson(response.data! as Map<String, dynamic>);
  }
}

// Providers
final bucketBalancesProvider = FutureProvider((ref) => ref.watch(reportsApiProvider).getBucketBalances());
final personBalancesProvider = FutureProvider((ref) => ref.watch(reportsApiProvider).getPersonBalances());
final monthlySummaryProvider = FutureProvider.family((ref, String? month) => ref.watch(reportsApiProvider).getMonthlySummary(month));

// Key format: "yyyy-MM-dd,yyyy-MM-dd"  — String has value equality, Map does not.
final tagTotalsProvider = FutureProvider.family((ref, String range) {
  final parts = range.split(',');
  return ref.watch(reportsApiProvider).getTagTotals(from: parts[0], to: parts[1]);
});

// Today's income/expense summary using local timezone boundaries.
// Key: "today" (constant — always fetches current day, no caching across days).
// Today: 00:00:00 → 23:59:59 of the current device date (full day, local timezone → UTC).
final todaySummaryProvider = FutureProvider.autoDispose((ref) {
  final now   = DateTime.now();
  final start = DateTime(now.year, now.month, now.day).toUtc();
  final end   = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc();
  return ref.watch(reportsApiProvider).getDateRangeSummary(
    start.toIso8601String(),
    end.toIso8601String(),
  );
});

// Date-range summary — key: "RFC3339from|RFC3339to"
final dateRangeSummaryProvider = FutureProvider.family((ref, String range) {
  final parts = range.split('|');
  return ref.watch(reportsApiProvider).getDateRangeSummary(parts[0], parts[1]);
});
