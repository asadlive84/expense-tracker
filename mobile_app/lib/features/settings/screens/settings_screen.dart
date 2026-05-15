import 'package:expense_tracker_app/core/theme/theme_controller.dart';
import 'package:expense_tracker_app/features/auth/data/auth_api.dart';
import 'package:expense_tracker_app/features/auth/providers/user_profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker_app/features/auth/providers/auth_controller.dart';
import 'package:expense_tracker_app/features/settings/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Manage section
          _SectionTitle(title: 'Manage'),
          _SettingsTile(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: cs.primary,
            title: 'Buckets',
            subtitle: 'Add, rename, archive money containers',
            onTap: () => context.push('/buckets'),
          ),
          _SettingsTile(
            icon: Icons.people_rounded,
            iconColor: Colors.orange,
            title: 'People',
            subtitle: 'Manage loan/repayment contacts',
            onTap: () => context.push('/people'),
          ),
          _SettingsTile(
            icon: Icons.label_rounded,
            iconColor: Colors.teal,
            title: 'Tags',
            subtitle: 'Manage spending categories',
            onTap: () => context.push('/tags'),
          ),

          const Divider(indent: 16, endIndent: 16),
          _SectionTitle(title: 'Appearance'),
          _SettingsTile(
            icon: Icons.brightness_6_rounded,
            iconColor: Colors.amber,
            title: 'Theme',
            subtitle: _themeModeLabel(themeMode),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode, size: 16)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                ref.read(themeControllerProvider.notifier).setTheme(s.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          const Divider(indent: 16, endIndent: 16),
          _SectionTitle(title: 'About'),
          _SettingsTile(
            icon: Icons.person_rounded,
            iconColor: Colors.purple,
            title: 'Developer',
            subtitle: 'Asaduzzaman Sohel · @asadlive84',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),

          const Divider(indent: 16, endIndent: 16),
          _SectionTitle(title: 'Account'),
          _UserProfileTile(),
          _SettingsTile(
            icon: Icons.bug_report_rounded,
            iconColor: Colors.deepOrange,
            title: 'Report an Issue',
            subtitle: 'Send feedback or bug report via email',
            onTap: () => _reportIssue(context),
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: cs.error,
            title: 'Sign Out',
            subtitle: 'Clear session and return to login',
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  void _reportIssue(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'asadlive.sohel@gmail.com',
      queryParameters: {
        'subject': 'Expense Tracker - Issue Report',
        'body': 'Hi,\n\nI found an issue:\n\n[Describe your issue here]\n\nApp version: 1.0.0\n',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Your session will be cleared.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      )),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
    onTap: onTap,
  );
}

class _UserProfileTile extends ConsumerStatefulWidget {
  const _UserProfileTile();

  @override
  ConsumerState<_UserProfileTile> createState() => _UserProfileTileState();
}

class _UserProfileTileState extends ConsumerState<_UserProfileTile> {
  @override
  Widget build(BuildContext context) {
    final nameAsync = ref.watch(userNameProvider);
    final name = nameAsync.value;
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: Text(
          name != null && name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name != null && name.isNotEmpty ? name : 'Add your name',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: name == null ? cs.onSurfaceVariant : null,
        ),
      ),
      subtitle: const Text('Name & phone — tap to edit'),
      trailing: const Icon(Icons.edit_rounded, size: 18),
      onTap: () => _showEditProfile(context),
    );
  }

  void _showEditProfile(BuildContext context) {
    final nameAsync = ref.read(userNameProvider);
    final nameCtrl = TextEditingController(text: nameAsync.value ?? '');
    final phoneCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit Profile',
              style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number (optional)',
                hintText: '+8801711000000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Changes are saved to your account.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                Navigator.pop(ctx);
                if (name.isEmpty) return;
                // Save locally
                await ref.read(userNameProvider.notifier).setName(name);
                // Sync to server
                try {
                  await ref.read(authApiProvider).updateProfile(
                    name: name,
                    phone: phone.isEmpty ? null : phone,
                  );
                } catch (_) {
                  // Server sync failed — local name already saved, show nothing
                }
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
