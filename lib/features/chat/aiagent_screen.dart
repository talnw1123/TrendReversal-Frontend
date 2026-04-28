import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';
import 'historychat_screen.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────
const Color _bgPrimary = Color(0xFF121212);
const Color _surfaceCard = Color(0xFF282828);
const Color _textPrimary = Colors.white;

// ─── Suggested questions mock data ─────────────────────────────────────────
const List<String> _suggestedQuestions = [
  'Is Bitcoin currently in an uptrend or downtrend?',
  'What is the long-term trend of Bitcoin based on historical data?',
  'Which crypto assets are outperforming Bitcoin right now?',
  'What is the current market trend for Bitcoin?',
];

// ═══════════════════════════════════════════════════════════════════════════
// AiAgentScreen
// ═══════════════════════════════════════════════════════════════════════════
class AiAgentScreen extends StatefulWidget {
  const AiAgentScreen({super.key});

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends State<AiAgentScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _startChat(String message) {
    if (message.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialMessage: message),
      ),
    );
  }

  void _showPromptGuidance() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PromptGuidanceSheet(
        onQuestionSelected: (q) {
          Navigator.pop(context);
          _startChat(q);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Header ──────────────────────────────────────────────
            _AppHeader(
              onHistoryTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryChatScreen()),
                );
              },
            ),
            // ── Hero + Input ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Spacer(),
                    // Hero text
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Talk with InsightGPT',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: _textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 12),
                          SvgPicture.asset(
                            'assets/images/logoai.svg',
                            width: 32,
                            height: 32,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chat bot for trade',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Input field
                    _ChatInputField(
                      controller: _inputController,
                      onSubmitted: _startChat,
                    ),
                    const SizedBox(height: 18),
                    // Prompt Guidance button
                    GestureDetector(
                      onTap: _showPromptGuidance,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Prompt Guidance',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
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

// ═══════════════════════════════════════════════════════════════════════════
// _AppHeader
// ═══════════════════════════════════════════════════════════════════════════
class _AppHeader extends StatelessWidget {
  final VoidCallback onHistoryTap;
  const _AppHeader({required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/profile_avatar_chat.jpg',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'InsightGPT',
                style: GoogleFonts.golosText(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onHistoryTap,
                child: SvgPicture.asset(
                  'assets/icons/history.svg',
                  width: 25,
                  height: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _ChatInputField
// ═══════════════════════════════════════════════════════════════════════════
class _ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const _ChatInputField({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _surfaceCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask anythink. Type for trade',
                hintStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (controller.text.trim().isNotEmpty) {
                onSubmitted(controller.text);
              }
            },
            child: Icon(
              Icons.send_rounded,
              size: 20,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptGuidanceSheet extends StatelessWidget {
  final ValueChanged<String> onQuestionSelected;
  const _PromptGuidanceSheet({required this.onQuestionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _bgPrimary, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Center(child: Container(width: 190, height: 4, decoration: BoxDecoration(color: _surfaceCard, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  Text('Suggested Questions', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w400, color: _textPrimary)),
                  const SizedBox(height: 6),
                  Text('Choose a question to ask InsightGPT', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.5))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: _suggestedQuestions.map((q) => _SuggestedQuestionItem(question: q, onTap: () => onQuestionSelected(q))).toList()),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SuggestedQuestionItem extends StatelessWidget {
  final String question;
  final VoidCallback onTap;
  const _SuggestedQuestionItem({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(border: Border.all(color: _surfaceCard, width: 1), borderRadius: BorderRadius.circular(10)),
        child: Text(question, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: _textPrimary)),
      ),
    ),
  );
}
