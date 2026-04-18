import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'ai_controller.dart';
import 'chat_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF191919);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF999999);
const Color _kRed = Color(0xFFE4472B);

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
    ).then((_) => _loadHistory()); // Refresh when coming back
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
        backgroundColor: _kCard,
        title: const Text('Rename Chat', style: TextStyle(color: _kWhite)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: _kWhite),
          decoration: const InputDecoration(
            hintText: 'Enter new title',
            hintStyle: TextStyle(color: _kGray),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kRed)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kRed)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _renameSession(session['id'], controller.text.trim());
            },
            child: const Text('Save', style: TextStyle(color: _kRed)),
          ),
        ],
      ),
    );
  }

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
                  ? const Center(child: CircularProgressIndicator(color: _kRed))
                  : _sessions.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: _kRed,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                            itemCount: _sessions.length,
                            itemBuilder: (_, i) => _ChatSessionItem(
                              session: _sessions[i],
                              onTap: () => _openChat(_sessions[i]['id']),
                              onDelete: () => _deleteSession(_sessions[i]['id']),
                              onRename: () => _showRenameDialog(_sessions[i]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();
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
              child: Image.asset('assets/icons/back_arrow.png', width: 20, height: 20, color: _kWhite),
            ),
          ),
          Text('Chat History', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w400, color: _kWhite)),
        ],
      ),
    );
  }
}

class _ChatSessionItem extends StatelessWidget {
  final dynamic session;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  const _ChatSessionItem({
    required this.session, 
    required this.onTap, 
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final title = session['title'] ?? 'Untitled Chat';
    final date = DateTime.parse(session['updatedAt'] ?? DateTime.now().toIso8601String());
    final dateStr = DateFormat('MMM d, HH:mm').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Icon(Icons.chat_bubble_outline_rounded, color: _kRed),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: _kWhite),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(dateStr, style: GoogleFonts.inter(fontSize: 12, color: _kGray)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white24, size: 20),
              onPressed: onRename,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: _kCard,
                    title: const Text('Delete Chat?', style: TextStyle(color: _kWhite)),
                    content: const Text('Are you sure you want to delete this conversation?', style: TextStyle(color: _kGray)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(onPressed: () { Navigator.pop(ctx); onDelete(); }, child: const Text('Delete', style: TextStyle(color: _kRed))),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            Text('No chat history found.', style: GoogleFonts.inter(color: _kGray)),
          ],
        ),
      );
}
