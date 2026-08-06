import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_services.dart';
import '../../../core/ai/llm_client.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/extensions/context_extensions.dart';

const _suggestions = [
  'Build me a grocery list under \$40',
  'Find the cheapest taco dinner',
  'Should I wait until next week to buy chicken?',
  'Find vegan alternatives to my list',
];

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  // Demo mode opens on a worked example so the assistant's value is
  // obvious before the first keystroke.
  final List<LlmMessage> _history = AppConfig.isDemoMode
      ? [
          const LlmMessage.user(
            'Should I wait until next week to buy chicken?',
          ),
          const LlmMessage.assistant(
            'Based on 12 weeks of price history, chicken breast at Aldi '
            'drops to about \$1.99/lb during their first-week-of-month '
            'sale — that is 4 days away. If your pantry covers dinners '
            'until then, waiting saves roughly \$4 on your list.',
          ),
        ]
      : [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearConversation() {
    // Undo instead of a confirm dialog, matching deletion flows elsewhere.
    final previous = List.of(_history);
    setState(() => _history.clear());
    context.showUndoSnack(
      'Conversation cleared',
      onUndo: () {
        if (!mounted) return;
        setState(() => _history.insertAll(0, previous));
      },
    );
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;
    setState(() {
      _history.add(LlmMessage.user(trimmed));
      _sending = true;
      _controller.clear();
    });
    _scrollToBottom();
    try {
      final reply = await ref.read(aiServicesProvider).chat(_history);
      if (!mounted) return;
      setState(() {
        _history.add(LlmMessage.assistant(reply));
        _sending = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      context.showSnack('Failed to get a response', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: _history.isEmpty ? null : _clearConversation,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _history.isEmpty
                  ? _SuggestionsView(onTap: _send)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length + (_sending ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= _history.length) return const _TypingBubble();
                        return _Bubble(message: _history[i]);
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      // Cap keeps a stray paste from blowing the LLM
                      // request; empty counterText hides the counter.
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        hintText: 'Ask about budgets, meals, prices…',
                        counterText: '',
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: _sending ? null : () => _send(_controller.text),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsView extends StatelessWidget {
  const _SuggestionsView({required this.onTap});

  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 40,
              color: context.colors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me anything about your groceries',
              textAlign: TextAlign.center,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _suggestions)
                  ActionChip(label: Text(s), onPressed: () => onTap(s)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final LlmMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final colors = context.colors;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? colors.primaryContainer : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: context.text.bodyMedium?.copyWith(
            color: isUser ? colors.onPrimaryContainer : colors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Thinking…',
          style: context.text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
