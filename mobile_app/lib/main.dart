import 'package:expense_tracker_app/app.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/core/storage/server_url_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved server URL before the app renders
  final savedUrl = await ServerUrlStorage.read();

  runApp(
    ProviderScope(
      overrides: [
        serverUrlProvider.overrideWith((ref) => savedUrl),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
