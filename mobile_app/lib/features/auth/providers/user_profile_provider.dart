import 'package:expense_tracker_app/core/storage/user_profile_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileStorageProvider = Provider((_) => UserProfileStorage());

final userNameProvider = AsyncNotifierProvider<UserNameController, String?>(() {
  return UserNameController();
});

class UserNameController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return ref.read(userProfileStorageProvider).readName();
  }

  Future<void> setName(String name) async {
    if (name.trim().isEmpty) return;
    await ref.read(userProfileStorageProvider).writeName(name);
    state = AsyncValue.data(name.trim());
  }

  Future<void> clear() async {
    await ref.read(userProfileStorageProvider).clear();
    state = const AsyncValue.data(null);
  }
}

final userEmailProvider = FutureProvider<String?>((ref) {
  return ref.read(userProfileStorageProvider).readEmail();
});
