import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/receipt_repositories.dart';
import '../domain/receipt.dart';

final receiptsProvider = FutureProvider<List<Receipt>>(
  (ref) => ref.watch(receiptRepositoryProvider).receipts(),
);

class ReceiptsScreen extends ConsumerWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(receiptsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Receipts')),
      body: AsyncValueWidget(
        value: receiptsAsync,
        onRetry: () => ref.invalidate(receiptsProvider),
        data: (receipts) => receipts.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No receipts yet',
                message: 'Scan a receipt to start tracking your spending.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: receipts.length,
                itemBuilder: (context, i) {
                  final receipt = receipts[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(receipt.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: context.colors.onError,
                        ),
                      ),
                      onDismissed: (_) async {
                        final repo = ref.read(receiptRepositoryProvider);
                        await repo.remove(receipt.id);
                        ref.invalidate(receiptsProvider);
                        Haptics.light();
                        if (context.mounted) {
                          context.showUndoSnack(
                            'Removed receipt from '
                            '${receipt.storeName ?? 'store'}',
                            onUndo: () async {
                              // Receipts feed the spending charts, so an
                              // accidental swipe would silently distort
                              // months of analytics.
                              await repo.add(receipt);
                              ref.invalidate(receiptsProvider);
                            },
                          );
                        }
                      },
                      child: _ReceiptCard(receipt: receipt),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/receipts/scan'),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan receipt'),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          receipt.storeName ?? 'Unknown store',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${Formatters.date(receipt.purchasedAt)} · ${receipt.items.length} item${receipt.items.length == 1 ? '' : 's'}',
        ),
        trailing: Text(
          Formatters.currency(receipt.total, code: receipt.currency),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          for (final item in receipt.items)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(child: Text(item.name)),
                  Text(Formatters.currency(item.price, code: receipt.currency)),
                ],
              ),
            ),
          if (receipt.items.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('No itemized items on this receipt.'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
