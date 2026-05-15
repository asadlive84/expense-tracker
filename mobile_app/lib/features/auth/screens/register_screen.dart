import 'package:expense_tracker_app/core/api/app_error.dart';
import 'package:expense_tracker_app/features/auth/providers/auth_controller.dart';
import 'package:expense_tracker_app/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  final _emailFocus    = FocusNode();
  final _phoneFocus    = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus  = FocusNode();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  S get l10n => S.of(context)!;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    _emailFocus.dispose(); _phoneFocus.dispose();
    _passwordFocus.dispose(); _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final phone    = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm  = _confirmCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.emailPasswordRequired);
      return;
    }
    if (password.length < 8) {
      setState(() => _error = l10n.passwordTooShort);
      return;
    }
    if (password != confirm) {
      setState(() => _error = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await ref.read(authControllerProvider.notifier).register(
        email, password,
        name: name.isEmpty ? null : name,
        phone: phone.isEmpty ? null : phone,
      );
    } on DioException catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } catch (_) {
      if (mounted) setState(() => _error = l10n.registerFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(DioException e) {
    final appErr = e.error;
    if (appErr is ConflictError)  return l10n.emailAlreadyRegistered;
    if (appErr is NetworkError)   return l10n.cannotReachServer;
    if (appErr is ServerError)    return l10n.serverError;
    return l10n.registerFailed;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.createAccount,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(l10n.startTracking,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center),
              const SizedBox(height: 28),

              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _emailFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: l10n.yourName,
                  hintText: 'e.g. Karim Hossain',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _phoneFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _phoneCtrl,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  hintText: '+8801711000000',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _confirmFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: l10n.passwordMin,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _confirmCtrl,
                focusNode: _confirmFocus,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) { if (!_loading) _register(); },
                decoration: InputDecoration(
                  labelText: l10n.confirmPassword,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

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

              FilledButton(
                onPressed: _loading ? null : _register,
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(l10n.createAccount,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.haveAccount),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
