import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/platform/platform_support.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Returns a barcode string via `Navigator.pop`.
///
/// Camera scanning needs `mobile_scanner`, which has no Windows/Linux
/// implementation, so desktop gets a keyboard entry form instead. Both
/// paths honour the same contract, so callers never branch on platform.
class BarcodeScanScreen extends StatelessWidget {
  const BarcodeScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformSupport.hasBarcodeScanner
        ? const _CameraScanner()
        : const _ManualBarcodeEntry();
  }
}

class _CameraScanner extends StatefulWidget {
  const _CameraScanner();

  @override
  State<_CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<_CameraScanner> {
  final _controller = MobileScannerController();
  bool _popped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_popped || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null) return;
    _popped = true;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            tooltip: 'Toggle torch',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Semantics(
            label: 'Point the camera at a barcode',
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desktop fallback: type or paste the number under the barcode.
class _ManualBarcodeEntry extends StatefulWidget {
  const _ManualBarcodeEntry();

  @override
  State<_ManualBarcodeEntry> createState() => _ManualBarcodeEntryState();
}

class _ManualBarcodeEntryState extends State<_ManualBarcodeEntry> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter barcode')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.keyboard_rounded,
                    size: 56,
                    color: context.colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera scanning is not available on '
                    '${PlatformSupport.platformName}',
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type or paste the number printed under the barcode.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Barcode number',
                      hintText: 'e.g. 0001001',
                      prefixIcon: Icon(Icons.qr_code_rounded),
                    ),
                    validator: (v) => (v == null || v.trim().length < 4)
                        ? 'Enter at least 4 digits'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Look up product'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
