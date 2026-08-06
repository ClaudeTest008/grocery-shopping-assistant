import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/ai_services.dart';
import '../../../core/observability/telemetry.dart';
import '../../../core/platform/platform_support.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../authentication/data/auth_repositories.dart';
import '../../products/data/price_observation_repository.dart';
import '../../products/data/product_repositories.dart';
import '../data/receipt_repositories.dart';
import '../domain/receipt.dart';
import '../domain/receipt_parser.dart';
import '../domain/receipt_price_recorder.dart';

enum _Stage { pickOptions, processing, confirm }

class ReceiptScanScreen extends ConsumerStatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ItemRow {
  _ItemRow({String? name, double? price})
    : nameCtrl = TextEditingController(text: name ?? ''),
      priceCtrl = TextEditingController(
        text: price == null ? '' : price.toStringAsFixed(2),
      );

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  _Stage _stage = _Stage.pickOptions;
  String? _receiptId;
  final _storeCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  DateTime _purchasedAt = DateTime.now();
  final List<_ItemRow> _rows = [];
  bool _saving = false;

  @override
  void dispose() {
    _storeCtrl.dispose();
    _totalCtrl.dispose();
    for (final r in _rows) {
      r.nameCtrl.dispose();
      r.priceCtrl.dispose();
    }
    super.dispose();
  }

  void _loadReceipt(Receipt r) {
    _receiptId = r.id;
    _storeCtrl.text = r.storeName ?? '';
    _totalCtrl.text = r.total.toStringAsFixed(2);
    _purchasedAt = r.purchasedAt;
    _rows
      ..clear()
      ..addAll([
        for (final i in r.items) _ItemRow(name: i.name, price: i.price),
      ]);
  }

  Future<void> _pickAndScan(ImageSource source) async {
    setState(() => _stage = _Stage.processing);
    try {
      final file = await ImagePicker().pickImage(source: source);
      if (file == null) {
        if (mounted) setState(() => _stage = _Stage.pickOptions);
        return;
      }
      // No on-device OCR on desktop/web: skip straight to the editable
      // form rather than round-tripping into a MissingPluginException.
      if (!PlatformSupport.hasOcr) {
        _startManualEntry();
        if (mounted) {
          context.showSnack(
            'Add the receipt lines below — text recognition is not '
            'available on ${PlatformSupport.platformName}.',
          );
        }
        return;
      }
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      String text;
      try {
        final recognized = await recognizer.processImage(
          InputImage.fromFilePath(file.path),
        );
        text = recognized.text;
      } finally {
        await recognizer.close();
      }
      final user = ref.read(currentUserProvider);
      final receipt = const ReceiptParser().parse(
        text,
        userId: user?.id ?? 'demo-user',
      );
      _loadReceipt(receipt);
      if (mounted) setState(() => _stage = _Stage.confirm);
    } catch (_) {
      if (mounted) {
        setState(() => _stage = _Stage.pickOptions);
        context.showSnack(
          'Could not scan that image. You can enter the receipt manually.',
          error: true,
        );
      }
    }
  }

  void _startManualEntry() {
    _receiptId = null;
    _storeCtrl.clear();
    _totalCtrl.clear();
    _purchasedAt = DateTime.now();
    _rows.clear();
    setState(() => _stage = _Stage.confirm);
  }

  Receipt _buildReceipt() {
    final user = ref.read(currentUserProvider);
    final receiptId = _receiptId ?? const Uuid().v4();
    final items = <ReceiptItem>[
      for (final row in _rows)
        if (row.nameCtrl.text.trim().isNotEmpty)
          ReceiptItem(
            id: const Uuid().v4(),
            receiptId: receiptId,
            name: row.nameCtrl.text.trim(),
            price: double.tryParse(row.priceCtrl.text.trim()) ?? 0,
          ),
    ];
    final total =
        double.tryParse(_totalCtrl.text.trim()) ??
        items.fold<double>(0.0, (sum, i) => sum + i.price);
    return Receipt(
      id: receiptId,
      userId: user?.id ?? 'demo-user',
      storeName: _storeCtrl.text.trim().isEmpty ? null : _storeCtrl.text.trim(),
      total: total,
      purchasedAt: _purchasedAt,
      items: items,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final receipt = _buildReceipt();
    // Read before awaits: this screen pops right after saving.
    final products = ref.read(productRepositoryProvider);
    final observations = ref.read(priceObservationRepositoryProvider);
    try {
      await ref.read(receiptRepositoryProvider).add(receipt);
      // Live data: matched lines become real price-history points.
      final recorded = await ReceiptPriceRecorder.record(
        receipt,
        products: products,
        observations: observations,
      );
      Telemetry.logEvent('receipt_prices_recorded', {
        'items': receipt.items.length,
        'recorded': recorded,
      });
      if (mounted) {
        context.showSnack(
          recorded > 0
              ? 'Receipt saved — $recorded price'
                    '${recorded == 1 ? '' : 's'} added to your history'
              : 'Receipt saved',
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        context.showSnack('Could not save receipt', error: true);
      }
    }
  }

  Future<void> _showAiSummary() async {
    final receipt = _buildReceipt();
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(width: 16),
              Text('Summarizing…'),
            ],
          ),
        ),
      ),
    );
    try {
      final summary = await ref
          .read(aiServicesProvider)
          .summarizeReceipt(receipt.toJson());
      if (!mounted) return;
      Navigator.of(context).pop();
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('AI summary'),
          content: Text(summary),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack('AI summary failed', error: true);
    }
  }

  bool get _hasFormContent =>
      _storeCtrl.text.trim().isNotEmpty ||
      _totalCtrl.text.trim().isNotEmpty ||
      _rows.any(
        (r) =>
            r.nameCtrl.text.trim().isNotEmpty ||
            r.priceCtrl.text.trim().isNotEmpty,
      );

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this receipt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchasedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchasedAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // OCR results and edits in the confirm form are only lost after an
      // explicit discard; the imperative pop in _save bypasses this.
      canPop: _stage != _Stage.confirm,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_hasFormContent) {
          Navigator.of(context).pop();
          return;
        }
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(switch (_stage) {
            _Stage.pickOptions => 'Add receipt',
            _Stage.processing => 'Scanning…',
            _Stage.confirm => 'Review receipt',
          }),
        ),
        body: switch (_stage) {
          _Stage.pickOptions => _PickOptions(
            onCamera: () => _pickAndScan(ImageSource.camera),
            onGallery: () => _pickAndScan(ImageSource.gallery),
            onManual: _startManualEntry,
          ),
          _Stage.processing => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Reading receipt…'),
              ],
            ),
          ),
          _Stage.confirm => _ConfirmForm(
            storeCtrl: _storeCtrl,
            totalCtrl: _totalCtrl,
            purchasedAt: _purchasedAt,
            rows: _rows,
            saving: _saving,
            onPickDate: _pickDate,
            onAddRow: () => setState(() => _rows.add(_ItemRow())),
            onRemoveRow: (row) => setState(() {
              _rows.remove(row);
              row.nameCtrl.dispose();
              row.priceCtrl.dispose();
            }),
            onAiSummary: _showAiSummary,
            onSave: _save,
          ),
        },
      ),
    );
  }
}

class _PickOptions extends StatelessWidget {
  const _PickOptions({
    required this.onCamera,
    required this.onGallery,
    required this.onManual,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Camera capture needs a mobile camera; desktop and web
              // pick an existing file instead.
              if (PlatformSupport.hasCamera) ...[
                _OptionCard(
                  icon: Icons.photo_camera_outlined,
                  label: 'Take photo',
                  onTap: onCamera,
                ),
                const SizedBox(height: 16),
              ],
              _OptionCard(
                icon: Icons.photo_library_outlined,
                label: PlatformSupport.hasCamera
                    ? 'Choose from gallery'
                    : 'Choose an image file',
                onTap: onGallery,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: onManual,
                child: const Text('Enter manually'),
              ),
              if (!PlatformSupport.hasOcr) ...[
                const SizedBox(height: 16),
                Text(
                  'Automatic text recognition is not available on '
                  '${PlatformSupport.platformName}. Pick an image to fill '
                  'the date and store, then add the lines yourself — or '
                  'enter everything manually.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, size: 32, color: colors.primary),
              const SizedBox(width: 20),
              Text(
                label,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmForm extends StatelessWidget {
  const _ConfirmForm({
    required this.storeCtrl,
    required this.totalCtrl,
    required this.purchasedAt,
    required this.rows,
    required this.saving,
    required this.onPickDate,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onAiSummary,
    required this.onSave,
  });

  final TextEditingController storeCtrl;
  final TextEditingController totalCtrl;
  final DateTime purchasedAt;
  final List<_ItemRow> rows;
  final bool saving;
  final VoidCallback onPickDate;
  final VoidCallback onAddRow;
  final void Function(_ItemRow) onRemoveRow;
  final VoidCallback onAiSummary;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        TextField(
          controller: storeCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Store name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: totalCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Total'),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(
            '${purchasedAt.month}/${purchasedAt.day}/${purchasedAt.year}',
          ),
          onTap: onPickDate,
        ),
        const SizedBox(height: 8),
        Text(
          'Items',
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: row.nameCtrl,
                    decoration: const InputDecoration(labelText: 'Item'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: row.priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove item',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => onRemoveRow(row),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: onAddRow,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add item'),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onAiSummary,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('AI summary'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Text('Save receipt'),
        ),
      ],
    );
  }
}
