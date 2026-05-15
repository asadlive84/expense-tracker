import 'package:expense_tracker_app/app.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/core/locale/locale_provider.dart';
import 'package:expense_tracker_app/core/storage/server_url_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final results = await Future.wait([
    ServerUrlStorage.read(),
    loadLocale(),
  ]);

  final savedUrl    = results[0] as String;
  final savedLocale = results[1] as Locale;

  runApp(
    ProviderScope(
      overrides: [
        serverUrlProvider.overrideWith((ref) => savedUrl),
        localeProvider.overrideWith((ref) => savedLocale),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
