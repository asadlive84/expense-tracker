import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/core/storage/default_source_storage.dart';
import 'package:expense_tracker_app/features/auth/data/auth_api.dart';
import 'package:expense_tracker_app/features/auth/data/auth_models.dart';
import 'package:expense_tracker_app/features/auth/providers/user_profile_provider.dart';
import 'package:expense_tracker_app/features/buckets/providers/buckets_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  final String userId;
  const Authenticated(this.userId);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  Future<void> checkAuth() async {
    try {
      final storage = ref.read(secureStorageProvider);

      // 4-second timeout per read — guards against Keystore hangs on real devices
      final token  = await storage.readToken().timeout(const Duration(seconds: 4));
      final expiry = await storage.readExpiry().timeout(const Duration(seconds: 4));

      if (token != null && (expiry == null || expiry.isAfter(DateTime.now()))) {
        ref.invalidate(userNameProvider);
        state = const Authenticated('me');
      } else {
        state = const Unauthenticated();
      }
    } catch (_) {
      // Secure storage failure or timeout → send to login, never stay on splash.
      state = const Unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    final api = ref.read(authApiProvider);
    final storage = ref.read(secureStorageProvider);
    final profile = ref.read(userProfileStorageProvider);

    final response = await api.login(LoginRequest(email: email, password: password));
    await storage.writeToken(response.token, response.expiresAt);
    await profile.writeEmail(email);
    if (response.name != null && response.name!.isNotEmpty) {
      await profile.writeName(response.name!);
      ref.read(userNameProvider.notifier).setName(response.name!);
    }
    // Sync default money source from server
    if (response.defaultBucketId != null) {
      ref.read(defaultMoneySourceProvider.notifier).state = response.defaultBucketId;
      await DefaultSourceStorage.write(response.defaultBucketId!);
    }
    state = Authenticated(response.userId ?? 'unknown');
  }

  Future<void> register(String email, String password, {String? name, String? phone}) async {
    final api = ref.read(authApiProvider);
    final storage = ref.read(secureStorageProvider);
    final profile = ref.read(userProfileStorageProvider);

    final response = await api.register(RegisterRequest(
      email: email, password: password,
      name: name?.trim().isEmpty == true ? null : name?.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
    ));
    await storage.writeToken(response.token, response.expiresAt);
    await profile.writeEmail(email);
    final savedName = response.name ?? name;
    if (savedName != null && savedName.trim().isNotEmpty) {
      await profile.writeName(savedName.trim());
      ref.read(userNameProvider.notifier).setName(savedName.trim());
    }
    state = Authenticated(response.userId ?? 'unknown');
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clear();
    ref.read(userNameProvider.notifier).clear();
    state = const Unauthenticated();
  }
}
