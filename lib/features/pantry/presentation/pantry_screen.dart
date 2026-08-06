import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../authentication/data/auth_repositories.dart';
import '../data/pantry_repositories.dart';
import '../domain/pantry_item.dart';

final pantryItemsProvider = FutureProvider<List<PantryItem>>(
  (ref) => ref.watch(pantryRepositoryProvider).items(),
);

const _units = [
  'ea',
  'lb',
  'oz',
  'gal',
  'can',
  'bag',
  'box',
  'bottle',
  'loaf',
  'tub',
];

const _locations = ['fridge', 'freezer', 'pantry'];

class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(pantryItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pantry')),
      body: AsyncValueWidget(
        value: itemsAsync,
        onRetry: () => ref.invalidate(pantryItemsProvider),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.kitchen_outlined,
                title: 'Your pantry is empty',
                message:
                    'Add items to track what you have and what\'s '
                    'about to expire.',
                actionLabel: 'Add item',
                onAction: () => _openSheet(context),
              )
            : _PantryList(items: items),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add item',
        onPressed: () => _openSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  static void _openSheet(BuildContext context, {PantryItem? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _PantryItemSheet(existing: existing),
      ),
    );
  }
}

class _PantryList extends ConsumerWidget {
  const _PantryList({required this.items});

  final List<PantryItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiringSoon = items.where((i) => i.expiresSoon).length;
    final expired = items.where((i) => i.isExpired).length;

    final grouped = <String, List<PantryItem>>{};
    for (final item in items) {
      final key = _locations.contains(item.location) ? item.location : 'other';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    final orderedKeys = [
      for (final l in _locations)
        if (grouped.containsKey(l)) l,
      if (grouped.containsKey('other')) 'other',
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  label: 'Items',
                  value: '${items.length}',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryChip(
                  label: 'Expiring soon',
                  value: '$expiringSoon',
                  icon: Icons.schedule_rounded,
                  tint: expiringSoon > 0 ? context.colors.errorContainer : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryChip(
                  label: 'Expired',
                  value: '$expired',
                  icon: Icons.error_outline_rounded,
                  tint: expired > 0 ? context.colors.error : null,
                  onColor: expired > 0 ? context.colors.onError : null,
                ),
              ),
            ],
          ),
        ),
        for (final key in orderedKeys) ...[
          SectionHeader(title: _titleCase(key)),
          for (final item in grouped[key]!)
            _PantryTile(
              key: ValueKey(item.id),
              item: item,
              onTap: () => PantryScreen._openSheet(context, existing: item),
              onDismissed: () async {
                final repo = ref.read(pantryRepositoryProvider);
                await repo.remove(item.id);
                ref.invalidate(pantryItemsProvider);
                Haptics.light();
                if (context.mounted) {
                  context.showUndoSnack(
                    'Removed ${item.name}',
                    onUndo: () async {
                      // The item is unchanged, so re-adding restores it
                      // exactly — same id, same expiry, same location.
                      await repo.upsert(item);
                      ref.invalidate(pantryItemsProvider);
                    },
                  );
                }
              },
            ),
        ],
      ],
    );
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    this.tint,
    this.onColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? tint;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = tint ?? colors.surfaceContainerHigh;
    final fg = onColor ?? colors.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: fg.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PantryTile extends StatelessWidget {
  const _PantryTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismissed,
  });

  final PantryItem item;
  final VoidCallback onTap;
  final Future<void> Function() onDismissed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: colors.error,
        child: Icon(Icons.delete_outline_rounded, color: colors.onError),
      ),
      onDismissed: (_) => onDismissed(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Card(
          child: ListTile(
            onTap: onTap,
            title: Text(item.name),
            subtitle: Text('${_formatQty(item.quantity)} ${item.unit}'),
            trailing: item.expiresAt == null ? null : _ExpiryChip(item: item),
          ),
        ),
      ),
    );
  }

  static String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();
}

class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color bg;
    final Color fg;
    if (item.isExpired) {
      bg = colors.error;
      fg = colors.onError;
    } else if (item.expiresSoon) {
      bg = colors.errorContainer;
      fg = colors.onErrorContainer;
    } else {
      bg = colors.surfaceContainerHigh;
      fg = colors.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        Formatters.relativeDays(item.expiresAt!),
        style: context.text.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PantryItemSheet extends ConsumerStatefulWidget {
  const _PantryItemSheet({this.existing});

  final PantryItem? existing;

  @override
  ConsumerState<_PantryItemSheet> createState() => _PantryItemSheetState();
}

class _PantryItemSheetState extends ConsumerState<_PantryItemSheet> {
  late final _nameCtrl = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _qtyCtrl = TextEditingController(
    text: _formatQty(widget.existing?.quantity ?? 1),
  );
  late String _unit = widget.existing?.unit ?? 'ea';
  late String _location = widget.existing?.location ?? 'pantry';
  DateTime? _expiresAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _expiresAt = widget.existing?.expiresAt;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  static String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final qty = double.tryParse(_qtyCtrl.text.trim());
    if (name.isEmpty || qty == null || qty <= 0) {
      context.showSnack('Enter a valid name and quantity', error: true);
      return;
    }
    setState(() => _saving = true);
    final user = ref.read(currentUserProvider);
    final item = PantryItem(
      id: widget.existing?.id ?? const Uuid().v4(),
      userId: user?.id ?? 'demo-user',
      name: name,
      quantity: qty,
      unit: _unit,
      location: _location,
      expiresAt: _expiresAt,
      addedAt: widget.existing?.addedAt ?? DateTime.now(),
    );
    try {
      await ref.read(pantryRepositoryProvider).upsert(item);
      ref.invalidate(pantryItemsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        context.showSnack('Could not save item', error: true);
      }
    }
  }

  Future<void> _delete() async {
    final item = widget.existing!;
    final repo = ref.read(pantryRepositoryProvider);
    // The sheet is gone by the time the undo fires, so the disposed ref
    // can't invalidate — the app-level container can.
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() => _saving = true);
    try {
      await repo.remove(item.id);
      ref.invalidate(pantryItemsProvider);
      Haptics.light();
      if (!mounted) return;
      context.showUndoSnack(
        'Removed ${item.name}',
        onUndo: () async {
          // The item is unchanged, so re-adding restores it
          // exactly — same id, same expiry, same location.
          await repo.upsert(item);
          container.invalidate(pantryItemsProvider);
        },
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        context.showSnack('Could not remove item', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit item' : 'Add item',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: [
                      for (final u in _units)
                        DropdownMenuItem(value: u, child: Text(u)),
                    ],
                    onChanged: (v) => setState(() => _unit = v ?? _unit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'fridge',
                  label: Text('Fridge'),
                  icon: Icon(Icons.kitchen_outlined),
                ),
                ButtonSegment(
                  value: 'freezer',
                  label: Text('Freezer'),
                  icon: Icon(Icons.ac_unit_rounded),
                ),
                ButtonSegment(
                  value: 'pantry',
                  label: Text('Pantry'),
                  icon: Icon(Icons.inventory_2_outlined),
                ),
              ],
              selected: {_location},
              onSelectionChanged: (s) => setState(() => _location = s.first),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                _expiresAt == null
                    ? 'No expiry date'
                    : Formatters.date(_expiresAt!),
              ),
              trailing: _expiresAt == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _expiresAt = null),
                    ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expiresAt ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (picked != null) setState(() => _expiresAt = picked);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(isEdit ? 'Save changes' : 'Add to pantry'),
            ),
            if (isEdit) ...[
              const SizedBox(height: 8),
              // No confirm dialog: the undo snack already covers mistakes.
              TextButton(
                onPressed: _saving ? null : _delete,
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.error,
                ),
                child: const Text('Delete item'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
