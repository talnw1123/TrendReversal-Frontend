import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_controller.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF282828);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kHint = Color(0x80FFFFFF);

// ─── Message Model ────────────────────────────────────────────────────────────
enum _Sender { user, ai }

class _ChatMessage {
  final String content;
  final _Sender sender;
  _ChatMessage(this.content, {required this.sender});
}

// ═══════════════════════════════════════════════════════════════════════════════
// ChatScreen
// ═══════════════════════════════════════════════════════════════════════════════
class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  final String? sessionId;
  const ChatScreen({super.key, this.initialMessage, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  final _aiCtrl = AiController();

  bool _loading = false;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.sessionId;

    if (_currentSessionId != null) {
      _loadSessionMessages();
    } else if (widget.initialMessage != null) {
      _messages.add(_ChatMessage(widget.initialMessage!, sender: _Sender.user));
      _startNewSessionAndSend(widget.initialMessage!);
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSessionMessages() async {
    setState(() => _loading = true);
    final data = await _aiCtrl.getSession(_currentSessionId!);
    if (mounted) {
      if (data != null && data['messages'] != null) {
        final List msgs = data['messages'];
        setState(() {
          _messages.clear();
          for (var m in msgs) {
            _messages.add(
              _ChatMessage(
                m['content'],
                sender: m['role'] == 'user' ? _Sender.user : _Sender.ai,
              ),
            );
          }
          _loading = false;
        });
        _scrollToBottom(immediate: true);
      } else {
        setState(() => _loading = false);
      }
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        if (immediate) {
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        } else {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> _startNewSessionAndSend(String text) async {
    setState(() => _loading = true);
    // 1. Create session (Title = initial message snippet)
    final title = text.length > 30 ? '${text.substring(0, 27)}...' : text;
    final session = await _aiCtrl.createSession(title);

    if (session != null && session['id'] != null) {
      _currentSessionId = session['id'];
      await _sendToAi(text, isNew: true);
    } else {
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage('เกิดข้อผิดพลาดในการสร้างเซสชัน', sender: _Sender.ai),
          );
          _loading = false;
        });
      }
    }
  }

  Future<void> _sendToAi(String text, {bool isNew = false}) async {
    if (!isNew) setState(() => _loading = true);
    _scrollToBottom();

    final result = await _aiCtrl.sendMessage(_currentSessionId!, text);

    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null && result['aiMessage'] != null) {
          _messages.add(
            _ChatMessage(result['aiMessage']['content'], sender: _Sender.ai),
          );
        } else {
          _messages.add(
            _ChatMessage(
              'ขออภัยครับ เกิดข้อผิดพลาดในการเชื่อมต่อกับ AI',
              sender: _Sender.ai,
            ),
          );
        }
      });
      _scrollToBottom();
    }
  }

  void _onSend() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_ChatMessage(text, sender: _Sender.user));
      _inputCtrl.clear();
    });

    if (_currentSessionId == null) {
      _startNewSessionAndSend(text);
    } else {
      _sendToAi(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const _ChatHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return const _LoadingBubble();
                  }
                  final msg = _messages[i];
                  return msg.sender == _Sender.user
                      ? _UserBubble(text: msg.content)
                      : _AiBubble(text: msg.content);
                },
              ),
            ),
            _InputBar(
              controller: _inputCtrl,
              onSend: _onSend,
              enabled: !_loading,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            children: [
              _BackButton(onTap: () => Navigator.pop(context)),
              Expanded(
                child: Center(
                  child: Text(
                    'InsightGPT',
                    style: GoogleFonts.golosText(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                  ),
                ),
              ),
              // Balance spacer to keep title centred
              const SizedBox(width: 44),
            ],
          ),
        ),
      ],
    );
  }
}

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

class _AiBubble extends StatelessWidget {
  final String text;
  const _AiBubble({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/logoai.svg',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _CopyButton(text: text),
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

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/logoai.svg',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              backgroundColor: _kCard,
              color: Color(0xFFE4472B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                style: GoogleFonts.inter(fontSize: 15, color: _kWhite),
                decoration: InputDecoration(
                  hintText: enabled
                      ? 'Enter question here...'
                      : 'InsightGPT is thinking...',
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: _kHint),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFDB2110), Color(0xFFEC6244)],
                ),
              ),
              child: Transform.translate(
                offset: const Offset(2, -2), // Shift slightly top-right
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: const Icon(
                    Icons.send_rounded,
                    color: _kWhite,
                    size: 26,
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

// ─── Back Button ─────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.05),
        child: Center(
          child: Image.asset(
            'assets/icons/back_icon.png',
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Copy Button with Animation ──────────────────────────────────────────────

class _CopyButton extends StatefulWidget {
  final String text;
  const _CopyButton({required this.text});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _isVisible = true;

  void _handleCopy() async {
    Clipboard.setData(ClipboardData(text: widget.text));

    // Animate fade out and in
    setState(() => _isVisible = false);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _isVisible = true);

    // Show SnackBar above the input bar
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'คัดลอกข้อความแล้ว',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE0543D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        // Elevate the snackbar so it sits above the InputBar
        margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleCopy,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: const Icon(
          Icons.copy_rounded,
          size: 16,
          color: Colors.white54,
        ),
      ),
    );
  }
}
