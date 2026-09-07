import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/auth_navigation_helper.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumModal extends StatefulWidget {
  const PremiumModal({super.key});

  @override
  State<PremiumModal> createState() => _PremiumModalState();
}

class _PremiumModalState extends State<PremiumModal> {
  String _selectedPlan = 'basic_ielts';
  bool _loading = false;
  String? _error;

  Future<void> _startCheckout() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ApiService.post('/payments/checkout', {
        'plan': _selectedPlan,
      });
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['success'] != true) {
        setState(() {
          _error = body['message']?.toString() ??
              'Unable to start checkout. Check Stripe config.';
        });
        return;
      }
      final url = body['data']?['url']?.toString();
      final sessionId = body['data']?['sessionId']?.toString();
      if (url == null || url.isEmpty) {
        setState(() => _error = 'Checkout URL missing from server');
        return;
      }
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        setState(() => _error = 'Could not open Stripe Checkout');
        return;
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Complete payment'),
          content: const Text(
            'Finish checkout in the browser, then tap “I’ve paid” to unlock your track.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                if (sessionId != null) {
                  await _confirmSession(sessionId);
                }
              },
              child: const Text("I've paid"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = 'Payment error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmSession(String sessionId) async {
    setState(() => _loading = true);
    try {
      final response =
          await ApiService.get('/payments/confirm?session_id=$sessionId');
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        final user = Map<String, dynamic>.from(body['user'] as Map? ?? {});
        if (user.isNotEmpty) {
          AuthNavigationHelper.syncUserNotifier(user);
        }
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment confirmed — your exam track is unlocked!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _error = body['message']?.toString() ??
              'Payment not confirmed yet. Try again in a moment.';
        });
      }
    } catch (e) {
      setState(() => _error = 'Confirm failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.dialogBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Unlock your exam track',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pay for IELTS, PTE, or both. You only see mocks for what you unlock.',
            style: TextStyle(color: AppTheme.secondaryText(context)),
          ),
          const SizedBox(height: 20),
          _planTile(
            keyName: 'basic_ielts',
            title: 'Basic IELTS',
            subtitle: 'All IELTS singular + full mocks',
            price: 'Rs 399',
          ),
          const SizedBox(height: 12),
          _planTile(
            keyName: 'basic_pte',
            title: 'Basic PTE',
            subtitle: 'All PTE full mocks',
            price: 'Rs 399',
          ),
          const SizedBox(height: 12),
          _planTile(
            keyName: 'premium',
            title: 'Premium',
            subtitle: 'IELTS + PTE unlocked',
            price: 'Rs 699',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _startCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Continue with Stripe',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTile({
    required String keyName,
    required String title,
    required String subtitle,
    required String price,
  }) {
    final selected = _selectedPlan == keyName;
    return InkWell(
      onTap: () => setState(() => _selectedPlan = keyName),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF007BFF) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? const Color(0xFF007BFF).withValues(alpha: 0.06)
              : AppTheme.inputFill(context),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF007BFF) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText(context),
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText(context),
                      )),
                ],
              ),
            ),
            Text(price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007BFF),
                )),
          ],
        ),
      ),
    );
  }
}
