import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF282828);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kHint = Color(0x80FFFFFF);
const Color _kRed = Color(0xFFE4472B);

// ─── Message Model ────────────────────────────────────────────────────────────
enum _Sender { user, ai }

class _ChatMessage {
  final String content;
  final _Sender sender;
  _ChatMessage(this.content, {required this.sender});
}

// ─── Initial mock conversation ────────────────────────────────────────────────
final List<_ChatMessage> _kInitialMessages = [
  _ChatMessage('Updated front-end UI', sender: _Sender.user),
  _ChatMessage(
    'Most recommended (natural & clear):\n'
    '• Updated UI components to improve UX\n\n'
    'More concise:\n'
    '• Improved UI components\n'
    '• Enhanced front-end UI\n\n'
    'Slightly more descriptive:\n'
    '• Refined front-end UI for better UX\n'
    '• Optimized UI components for usability\n\n'
    'If this is for a Today / Earlier section, this wording fits perfectly without needing a date.',
    sender: _Sender.ai,
  ),
  _ChatMessage('More detail', sender: _Sender.user),
];

// ═══════════════════════════════════════════════════════════════════════════════
// ChatScreen
// ═══════════════════════════════════════════════════════════════════════════════
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(_kInitialMessages);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, sender: _Sender.user));
      _inputCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            const _ChatHeader(),
            // ── Messages ────────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final msg = _messages[i];
                  if (msg.sender == _Sender.user) {
                    return _UserBubble(text: msg.content);
                  }
                  return _AiBubble(text: msg.content);
                },
              ),
            ),
            // ── Input Bar ───────────────────────────────────────────────────
            _InputBar(
              controller: _inputCtrl,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _ChatHeader
// ═══════════════════════════════════════════════════════════════════════════════
class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'assets/icons/back_arrow.png',
                width: 20,
                height: 20,
                color: _kWhite,
              ),
            ),
          ),
          Text(
            'Quantix',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: _kWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _UserBubble
// ═══════════════════════════════════════════════════════════════════════════════
class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _kWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _AiBubble
// ═══════════════════════════════════════════════════════════════════════════════
class _AiBubble extends StatelessWidget {
  final String text;
  const _AiBubble({required this.text});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied to clipboard',
          style: GoogleFonts.inter(fontSize: 13, color: _kWhite),
        ),
        backgroundColor: _kCard,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          Image.asset(
            'assets/images/ai_avatar.png',
            width: 40,
            height: 38,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          // Response text + actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: _kWhite,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                // Action row: copy + refresh
                Row(
                  children: [
                    _ActionIconButton(
                      iconPath: 'assets/icons/copy_icon.png',
                      tooltip: 'Copy',
                      onTap: () => _copyToClipboard(context),
                    ),
                    const SizedBox(width: 16),
                    _ActionIconButton(
                      iconPath: 'assets/icons/refresh_icon.png',
                      tooltip: 'Regenerate',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _ActionIconButton
// ═══════════════════════════════════════════════════════════════════════════════
class _ActionIconButton extends StatelessWidget {
  final String iconPath;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.iconPath,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset(
          iconPath,
          width: 20,
          height: 20,
          color: _kWhite.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _InputBar
// ═══════════════════════════════════════════════════════════════════════════════
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Input field ──────────────────────────────────────────────────
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _kCard,
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
                        color: _kWhite,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter question here...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: _kHint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => onSend(),
                      cursorColor: _kWhite,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                      'assets/icons/microphone_icon.png',
                      width: 20,
                      height: 20,
                      color: _kWhite.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── Send button ──────────────────────────────────────────────────
          _SendButton(onTap: onSend),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _SendButton  – red gradient circle with paper-plane icon
// ═══════════════════════════════════════════════════════════════════════════════
class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Color(0xFFDB2110), // matches SVG stop 0%
              Color(0xFFEC6244), // matches SVG stop 100%
            ],
          ),
        ),
        child: const Icon(
          Icons.send_rounded,
          color: _kWhite,
          size: 24,
        ),
      ),
    );
  }
}
