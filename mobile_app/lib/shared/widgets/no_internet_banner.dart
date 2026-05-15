import 'package:expense_tracker_app/core/network/connectivity_provider.dart';
import 'package:expense_tracker_app/core/network/server_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Drop this inside MaterialApp.builder so it has Theme + Directionality.
/// Shows a full-screen overlay when the device is offline or the server is down.
class NoInternetWrapper extends ConsumerWidget {
  final Widget child;
  const NoInternetWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final serverStatus = ref.watch(serverStatusProvider);

    final showNoInternet = !isOnline;
    final showServerDown = isOnline && serverStatus == ServerStatus.down;

    if (!showNoInternet && !showServerDown) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: showNoInternet
              ? const _Overlay(type: _OverlayType.noInternet)
              : const _Overlay(type: _OverlayType.serverDown),
        ),
      ],
    );
  }
}

enum _OverlayType { noInternet, serverDown }

class _Overlay extends StatelessWidget {
  final _OverlayType type;
  const _Overlay({required this.type});

  bool get _isNoInternet => type == _OverlayType.noInternet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _isNoInternet ? Colors.orange : Colors.red.shade400;

    return Material(
      color: cs.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isNoInternet
                      ? Icons.wifi_off_rounded
                      : Icons.cloud_off_rounded,
                  size: 54,
                  color: color,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                _isNoInternet
                    ? 'No Internet Connection'
                    : 'Server Unavailable',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                _isNoInternet
                    ? 'Please check your Wi-Fi or mobile data\nand try again.'
                    : 'We\'re having trouble reaching the server.\n'
                        'This is usually temporary — we\'ll retry\n'
                        'automatically every 15 seconds.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),

              const SizedBox(height: 24),

              // Retrying spinner (server down only)
              if (!_isNoInternet) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Retrying automatically…',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  icon: const Icon(Icons.email_outlined, size: 16),
                  label: const Text('Report this issue'),
                  onPressed: _reportIssue,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reportIssue() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'asadlive.sohel@gmail.com',
      queryParameters: {
        'subject': 'Expense Tracker – Server Unavailable',
        'body': 'Hi,\n\nI cannot connect to the server.\n'
            'Time: ${DateTime.now().toLocal()}\n\n'
            '[Any additional details here]',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
