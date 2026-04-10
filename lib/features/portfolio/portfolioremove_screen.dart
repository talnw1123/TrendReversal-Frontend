import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'portfolio_controller.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kSectionBg = Color(0xFF000000);
const Color _kCard = Color(0xFF191919);
const Color _kBtn = Color(0xFF282828);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kRed = Color(0xFFE4472B);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite80 = Color(0xCCFFFFFF);
const Color _kGray = Color(0xFF595959);
const Color _kDivider = Color(0xFF1F1F1F);
const Color _kDark = Color(0xFF050505);

// ─── Screen ───────────────────────────────────────────────────────────────────
class PortfolioRemoveScreen extends StatefulWidget {
  const PortfolioRemoveScreen({super.key});

  @override
  State<PortfolioRemoveScreen> createState() => _PortfolioRemoveScreenState();
}

class _PortfolioRemoveScreenState extends State<PortfolioRemoveScreen> {
  final _ctrl = PortfolioController();
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _ctrl.getPortfolioData();
      setState(() {
        _items = data['history'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'โหลดข้อมูลไม่สำเร็จ';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Portfolio',
                style: GoogleFonts.inter(fontSize: 24, color: _kWhite)),
            const SizedBox(height: 20),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _kRed));
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: _kWhite80)));

    return Column(
      children: [
        _sectionHeader('Remove Asset'),
        const SizedBox(height: 20),
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text('ไม่มีสินทรัพย์ที่สามารถลบได้', style: TextStyle(color: _kWhite80)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _AssetRemoveItem(
                    item: _items[index],
                    onRemove: () => _confirmRemove(_items[index]),
                  ),
                ),
        ),
        _bottomActions(),
      ],
    );
  }

  Widget _sectionHeader(String label) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: _kSectionBg,
        child: Center(
          child: Text(label,
              style: GoogleFonts.golosText(
                  fontSize: 20, fontWeight: FontWeight.w600, color: _kRed)),
        ),
      );

  Future<void> _confirmRemove(dynamic item) async {
    final name = item['assetLabel'] as String? ?? item['assetId'] as String? ?? 'Asset';
    final id = item['id'].toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        title: const Text('ลบสินทรัพย์', style: TextStyle(color: _kWhite)),
        content: Text('คุณต้องการลบ $name หรือไม่?', style: const TextStyle(color: _kWhite80)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ', style: TextStyle(color: _kRed))),
        ],
      ),
    );

    if (confirm == true) {
      await _ctrl.deleteItem(id);
      _load();
    }
  }

  Widget _bottomActions() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Row(
          children: [
            Expanded(
              child: _btn('Cancel', _kBtn, _kWhite, () => Navigator.pop(context)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _btn('Done', _kGreen, _kDark, () => Navigator.pop(context, true)),
            ),
          ],
        ),
      );

  Widget _btn(String label, Color bg, Color text, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600, color: text))),
        ),
      );
}

class _AssetRemoveItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRemove;
  const _AssetRemoveItem({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final name = item['assetLabel'] as String? ?? item['assetId'] as String? ?? 'Unknown';
    final symbol = item['assetId'] as String? ?? '';
    final qty = item['quantity']?.toString() ?? '0';

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kDivider)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: _kBtn, shape: BoxShape.circle),
            child: Center(
                child: Text(symbol.isNotEmpty ? symbol[0] : '?',
                    style: const TextStyle(color: _kWhite, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 15, color: _kWhite)),
                Text('x$qty', style: GoogleFonts.inter(fontSize: 13, color: _kWhite80)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _kRed.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.close, color: _kRed, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
