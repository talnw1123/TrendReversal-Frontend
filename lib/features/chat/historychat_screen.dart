import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import SVG
import 'ai_controller.dart';
import 'chat_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg   = Color(0xFF121212);
const Color _kCard = Color(0xFF282828);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray  = Color(0xFF999999);
const Color _kRed   = Color(0xFFE4472B);

// ═══════════════════════════════════════════════════════════════════════════════
// HistoryChatScreen
// ═══════════════════════════════════════════════════════════════════════════════
class HistoryChatScreen extends StatefulWidget {
  const HistoryChatScreen({super.key});

  @override
  State<HistoryChatScreen> createState() => _HistoryChatScreenState();
}

class _HistoryChatScreenState extends State<HistoryChatScreen> {
  final _aiCtrl = AiController();
  bool _loading = true;
  List<dynamic> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ── Logic (unchanged) ──────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final data = await _aiCtrl.getChatSessions();
    if (mounted) {
      setState(() {
        _sessions = data;
        _loading = false;
      });
    }
  }

  void _openChat(String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(sessionId: sessionId),
      ),
    ).then((_) => _loadHistory());
  }

  Future<void> _deleteSession(String id) async {
    await _aiCtrl.deleteSession(id);
    _loadHistory();
  }

  Future<void> _renameSession(String id, String newTitle) async {
    final ok = await _aiCtrl.renameSession(id, newTitle);
    if (ok) _loadHistory();
  }

  void _showRenameDialog(dynamic session) {
    final controller = TextEditingController(text: session['title']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Rename Chat', style: TextStyle(color: _kWhite)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: _kWhite),
          decoration: const InputDecoration(
            hintText: 'Enter new title',
            hintStyle: TextStyle(color: _kGray),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _kRed)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _kRed)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: _kGray))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _renameSession(session['id'], controller.text.trim());
            },
            child: Text('Save',
                style: GoogleFonts.inter(color: _kRed)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Chat?',
            style: TextStyle(color: _kWhite)),
        content: const Text(
            'Are you sure you want to delete this conversation?',
            style: TextStyle(color: _kGray)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: _kGray))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSession(session['id']);
            },
            child: Text('Delete',
                style: GoogleFonts.inter(color: _kRed)),
          ),
        ],
      ),
    );
  }

  // ── Date grouping ─────────────────────────────────────────────────────────

  bool _isToday(dynamic session) {
    try {
      final d = DateTime.parse(session['updatedAt'] ?? '');
      final now = DateTime.now();
      return d.year == now.year &&
          d.month == now.month &&
          d.day == now.day;
    } catch (_) {
      return false;
    }
  }

  List<dynamic> get _todaySessions =>
      _sessions.where(_isToday).toList();

  List<dynamic> get _previousSessions =>
      _sessions.where((s) => !_isToday(s)).toList();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            const _AppHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kRed))
                  : _sessions.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: _kRed,
                          child: _buildSessionList(),
                        ),
            ),
            _StartNewChatButton(onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    final today = _todaySessions;
    final previous = _previousSessions;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      children: [
        if (today.isNotEmpty) ...[
          const _SectionLabel(label: 'Today'),
          const SizedBox(height: 10),
          ...today.map((s) => _ChatSessionItem(
                session: s,
                onTap: () => _openChat(s['id']),
                onRename: () => _showRenameDialog(s),
                onDelete: () => _showDeleteDialog(s),
              )),
          const SizedBox(height: 12),
        ],
        if (previous.isNotEmpty) ...[
          const _SectionLabel(label: 'Previous'),
          const SizedBox(height: 10),
          ...previous.map((s) => _ChatSessionItem(
                session: s,
                onTap: () => _openChat(s['id']),
                onRename: () => _showRenameDialog(s),
                onDelete: () => _showDeleteDialog(s),
              )),
        ],
      ],
    );
  }
}

// ─── App Header ───────────────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  const _AppHeader();

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
                    'Chat History',
                    style: GoogleFonts.golosText(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
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
            color: _kWhite,
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _kWhite,
        ),
      ),
    );
  }
}

// ─── Chat Session Item ────────────────────────────────────────────────────────
// ─── Chat Session Item ────────────────────────────────────────────────────────
class _ChatSessionItem extends StatefulWidget {
  final dynamic session;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ChatSessionItem({
    required this.session,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  State<_ChatSessionItem> createState() => _ChatSessionItemState();
}

class _ChatSessionItemState extends State<_ChatSessionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.session['title'] ?? 'Untitled Chat';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF323232) : _kCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              // Session icon (SVG)
              SvgPicture.asset(
                'assets/icons/chathistory.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  _kWhite,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 14),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: _kWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Three-dot menu (Show only on hover)
              _ThreeDotMenu(
                onRename: widget.onRename,
                onDelete: widget.onDelete,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Three-Dot Menu ──────────────────────────────────────────────────────────
class _ThreeDotMenu extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ThreeDotMenu({required this.onRename, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: _kWhite, size: 20),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val == 'rename') onRename();
        if (val == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/rename.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  _kWhite,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Rename',
                style: GoogleFonts.inter(color: _kWhite, fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/bin.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  _kRed,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Delete',
                style: GoogleFonts.inter(color: _kRed, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Start New Chat Button ────────────────────────────────────────────────────
class _StartNewChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartNewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kRed,
            foregroundColor: _kWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
                'Start new chat',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _kWhite,
                ),
              ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: Colors.white12),
          const SizedBox(height: 16),
          Text(
            'No chat history found.',
            style: GoogleFonts.inter(color: _kGray, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
