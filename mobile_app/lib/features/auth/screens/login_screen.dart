import 'package:expense_tracker_app/core/api/app_error.dart';
import 'package:expense_tracker_app/core/api/api_client.dart';
import 'package:expense_tracker_app/features/auth/providers/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await ref.read(authControllerProvider.notifier).login(email, password);
      // GoRouter redirect fires automatically when AuthState → Authenticated
    } on DioException catch (e) {
      setState(() => _error = _friendlyError(e));
    } catch (_) {
      setState(() => _error = 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(DioException e) {
    final appErr = e.error;
    final url = ref.read(serverUrlProvider);
    if (appErr is UnauthorizedError) return 'Incorrect email or password.';
    if (appErr is NetworkError)      return 'Cannot reach the server ($url).\nCheck your connection or update the Server URL in Settings.';
    if (appErr is ServerError)       return 'Server error. Please try again later.';
    return 'Login failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Icon + title
                Icon(Icons.account_balance_wallet_rounded,
                    size: 64, color: cs.primary),
                const SizedBox(height: 16),
                Text('Expense Tracker',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Sign in to continue',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center),

                const SizedBox(height: 40),

                // Email field
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                // Password field
                TextField(
                  controller: _passwordCtrl,
                  focusNode: _passwordFocus,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) { if (!_loading) _login(); },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),

                // Error banner
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 18, color: cs.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: TextStyle(
                                  color: cs.onErrorContainer, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Sign in button
                FilledButton(
                  onPressed: _loading ? null : _login,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Sign In',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text("Don't have an account? Create one"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
