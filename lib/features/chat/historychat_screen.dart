import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF282828);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF999999);
const Color _kRed = Color(0xFFE4472B);

// ─── Chat Entry Type ──────────────────────────────────────────────────────────
enum _ChatType { text, voice }

// ─── Mock Data ────────────────────────────────────────────────────────────────
class _ChatEntry {
  final String title;
  final _ChatType type;
  const _ChatEntry(this.title, this.type);
}

const List<_ChatEntry> _kToday = [
  _ChatEntry('Updated front-end UI component...', _ChatType.text),
  _ChatEntry('Refactored front-end code to imp...', _ChatType.text),
  _ChatEntry('Fixed front-end bugs reported by...', _ChatType.voice),
];

const List<_ChatEntry> _kPrevious = [
  _ChatEntry('Optimized front-end layout and st...', _ChatType.text),
  _ChatEntry('Enhanced front-end accessibility...', _ChatType.text),
  _ChatEntry('Fixed front-end bugs reported by...', _ChatType.voice),
  _ChatEntry('Fixed front-end bugs reported by...', _ChatType.voice),
];

// ═══════════════════════════════════════════════════════════════════════════════
// HistoryChatScreen
// ═══════════════════════════════════════════════════════════════════════════════
class HistoryChatScreen extends StatelessWidget {
  const HistoryChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Header ──────────────────────────────────────────────────
            const _AppHeader(),
            // ── Scrollable List ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                children: [
                  // Today section
                  _SectionLabel('Today'),
                  const SizedBox(height: 10),
                  ..._kToday.map((e) => _ChatItem(entry: e)),
                  const SizedBox(height: 20),
                  // Previous section
                  _SectionLabel('Previous'),
                  const SizedBox(height: 10),
                  ..._kPrevious.map((e) => _ChatItem(entry: e)),
                ],
              ),
            ),
            // ── Start New Chat Button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: _StartNewChatButton(
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _AppHeader
// ═══════════════════════════════════════════════════════════════════════════════
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button
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
          // Centered title
          Text(
            'Recent History',
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
// _SectionLabel
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _kWhite,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _ChatItem
// ═══════════════════════════════════════════════════════════════════════════════
class _ChatItem extends StatelessWidget {
  final _ChatEntry entry;
  const _ChatItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          splashColor: _kWhite.withValues(alpha: 0.05),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Chat type icon
                Image.asset(
                  entry.type == _ChatType.text
                      ? 'assets/icons/bubble_chat_icon.png'
                      : 'assets/icons/microphone_icon.png',
                  width: 20,
                  height: 20,
                  color: _kWhite,
                ),
                const SizedBox(width: 14),
                // Title (truncated)
                Expanded(
                  child: Text(
                    entry.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Three-dot menu
                GestureDetector(
                  onTap: () => _showItemMenu(context, entry.title),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: const Icon(
                      Icons.more_vert,
                      color: _kWhite,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showItemMenu(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemMenuSheet(title: title),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _ItemMenuSheet  (bottom sheet for per-item actions)
// ═══════════════════════════════════════════════════════════════════════════════
class _ItemMenuSheet extends StatelessWidget {
  final String title;
  const _ItemMenuSheet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _kGray.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _kGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          _MenuAction(
            icon: Icons.open_in_new,
            label: 'Open chat',
            onTap: () => Navigator.pop(context),
          ),
          _MenuAction(
            icon: Icons.edit_outlined,
            label: 'Rename',
            onTap: () => Navigator.pop(context),
          ),
          _MenuAction(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: _kRed,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = _kWhite,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _StartNewChatButton
// ═══════════════════════════════════════════════════════════════════════════════
class _StartNewChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartNewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kRed,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: _kWhite, size: 20),
              const SizedBox(width: 8),
              Text(
                'Start new chat',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _kWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
