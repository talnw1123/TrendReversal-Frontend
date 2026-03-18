import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────
const Color _bgPrimary = Color(0xFF121212);
const Color _surfaceCard = Color(0xFF282828);
const Color _textPrimary = Colors.white;
const Color _textSecondary = Color(0xFFCCCCCC); // white 80%
const Color _textHint = Color(0xFF808080); // white 50%

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

  void _showPromptGuidance() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PromptGuidanceSheet(
        onQuestionSelected: (q) {
          Navigator.pop(context);
          setState(() => _inputController.text = q);
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
            _AppHeader(),
            // ── Hero + Input ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Spacer(),
                    // Hero text
                    Text(
                      'Talk with Quantix',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: _textPrimary,
                      ),
                      textAlign: TextAlign.center,
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
                    _ChatInputField(controller: _inputController),
                    const SizedBox(height: 18),
                    // Prompt Guidance button
                    GestureDetector(
                      onTap: _showPromptGuidance,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Profile avatar – rounded square
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/profile_avatar_chat.jpg',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          // Title centered
          const Expanded(
            child: Center(
              child: Text(
                'Quantix',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
          // History / clock icon
          Image.asset(
            'assets/icons/history_icon.png',
            width: 25,
            height: 25,
            color: Colors.white,
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

  const _ChatInputField({required this.controller});

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
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: _textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Ask anythink. Type for trade',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/icons/microphone_icon.png',
            width: 20,
            height: 20,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _PromptGuidanceSheet  (bottom sheet content)
// ═══════════════════════════════════════════════════════════════════════════
class _PromptGuidanceSheet extends StatelessWidget {
  final ValueChanged<String> onQuestionSelected;

  const _PromptGuidanceSheet({required this.onQuestionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Drag handle
          Center(
            child: Container(
              width: 190,
              height: 4,
              decoration: BoxDecoration(
                color: _surfaceCard,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(width: double.infinity),
                // Title + subtitle centered
                Column(
                  children: [
                    Text(
                      'Suggested Questions',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose a question to ask Quantix',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                // Close button top-right
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/close_icon.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Question cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: _suggestedQuestions
                  .map(
                    (q) => _SuggestedQuestionItem(
                      question: q,
                      onTap: () => onQuestionSelected(q),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _SuggestedQuestionItem
// ═══════════════════════════════════════════════════════════════════════════
class _SuggestedQuestionItem extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _SuggestedQuestionItem({required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: _surfaceCard, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            question,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
