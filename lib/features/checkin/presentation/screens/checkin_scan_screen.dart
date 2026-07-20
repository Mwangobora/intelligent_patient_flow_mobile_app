import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';

class CheckinScanScreen extends ConsumerStatefulWidget {
  const CheckinScanScreen({super.key});

  @override
  ConsumerState<CheckinScanScreen> createState() => _CheckinScanScreenState();
}

class _CheckinScanScreenState extends ConsumerState<CheckinScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppSizes.radius),
                    ),
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) =>
                          _CameraPermissionView(onRetry: _restartScanner),
                      overlayBuilder: (context, constraints) =>
                          const _ScannerOverlay(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: _ManualEntryCard(
                    controller: _manualController,
                    errorMessage: _errorMessage,
                    isSubmitting: _isSubmitting,
                    onSubmit: () => _submitToken(_manualController.text),
                  ),
                ),
              ],
            ),
            if (_isSubmitting)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: AppSizes.md),
                          Text('Completing check-in...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isSubmitting) return;
    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (rawValue == null) return;
    _submitToken(rawValue);
  }

  Future<void> _submitToken(String rawContent) async {
    final token = _extractToken(rawContent);
    if (token == null || token.isEmpty) {
      setState(() => _errorMessage = 'This QR code is not valid.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    await _scannerController.stop();
    final success = await ref
        .read(checkinControllerProvider.notifier)
        .consumeQrToken(token);
    if (!mounted) return;
    final state = ref.read(checkinControllerProvider);
    setState(() {
      _isSubmitting = false;
      _errorMessage = success ? null : state.errorMessage;
    });
    if (success) {
      _showSuccessSheet(state.successMessage ?? 'Check-in successful.');
    } else {
      await _scannerController.start();
    }
  }

  Future<void> _restartScanner() async {
    setState(() => _errorMessage = null);
    await _scannerController.start();
  }

  String? _extractToken(String rawContent) {
    final content = rawContent.trim();
    if (content.isEmpty) return null;
    final decoded = _tryDecodeTokenJson(content);
    if (decoded != null) return decoded;
    final uri = Uri.tryParse(content);
    final queryToken = uri?.queryParameters['token'];
    if (queryToken != null && queryToken.trim().isNotEmpty) {
      return queryToken.trim();
    }
    return content;
  }

  String? _tryDecodeTokenJson(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        final value = decoded['token'] ?? decoded['code'];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> _showSuccessSheet(String message) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 48,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Check-in successful',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.lg),
            AppButton(
              label: 'View Queue Status',
              onPressed: () => context.go('/queue'),
            ),
            const SizedBox(height: AppSizes.sm),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.softCyan, width: 4),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: const Center(
          child: Text(
            'Place QR code inside the frame',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _CameraPermissionView extends StatelessWidget {
  const _CameraPermissionView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.darkNavy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: AppColors.warning,
                size: 48,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Camera permission is required to scan QR codes.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'Allow camera access in your phone settings, then try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.softCyan),
              ),
              const SizedBox(height: AppSizes.lg),
              AppButton(label: 'Try again', onPressed: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualEntryCard extends StatelessWidget {
  const _ManualEntryCard({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Manual code entry',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.sm),
          AppTextField(
            label: 'QR code',
            controller: controller,
            hintText: 'Paste or type the QR code',
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSizes.md),
          AppButton(
            label: 'Submit code',
            isLoading: isSubmitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
