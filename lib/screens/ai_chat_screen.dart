// lib/screens/ai_chat_screen.dart
//
// "AI Chat Assistant" from the blueprint:
// - Ask nutrition-related questions
// - Healthy food recommendations
// - Personalized dietary suggestions
// - Meal substitution advice
// - Fitness nutrition guidance
//
// `_sendToAssistant` is a stub — wire it to Gemini API / OpenAI API
// via a Cloud Function so your API key never ships in the app.

import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime sentAt;

  ChatMessage({required this.text, required this.isUser, DateTime? sentAt})
      : sentAt = sentAt ?? DateTime.now();
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      isUser: false,
      text: "Hi! I'm your AMUDHU nutrition assistant. Ask me about "
          "meal substitutions, macros, or fitness nutrition — I'm here to help.",
    ),
  ];
  bool _isThinking = false;

  static const List<String> _suggestedPrompts = [
    'Healthy swap for white rice?',
    'High-protein vegetarian snacks',
    'Is this good post-workout?',
  ];

  Future<void> _handleSend([String? preset]) async {
    final text = (preset ?? _inputController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _inputController.clear();
      _isThinking = true;
    });
    _scrollToBottom();

    final reply = await _sendToAssistant(text);

    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false));
      _isThinking = false;
    });
    _scrollToBottom();
  }

  /// Replace with a real backend call, e.g.:
  /// final resp = await FirebaseFunctions.instance
  ///     .httpsCallable('nutritionAssistant')
  ///     .call({'message': userText, 'userGoal': goal.toJson()});
  Future<String> _sendToAssistant(String userText) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return "Based on a balanced diet, here's a suggestion for \"$userText\": "
        "try pairing it with a fiber-rich vegetable and a lean protein source "
        "to keep your blood sugar stable.";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Nutrition Assistant')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const _ThinkingBubble();
                  }
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            if (_messages.length <= 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestedPrompts
                      .map((p) => ActionChip(
                            label: Text(p),
                            onPressed: () => _handleSend(p),
                          ))
                      .toList(),
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Ask about nutrition...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _handleSend,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
              color: isUser ? Colors.white : Colors.black87, height: 1.4),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const SizedBox(
          width: 36,
          height: 16,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}
