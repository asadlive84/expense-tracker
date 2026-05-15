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
