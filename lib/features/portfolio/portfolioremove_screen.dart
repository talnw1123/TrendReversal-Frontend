import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'portfolio_controller.dart';
import '../../core/currency_provider.dart';
import '../../core/asset_helper.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kSectionBg = Color(0xFF191919);
const Color _kInputBg = Color(0xFF282828);
const Color _kRed = Color(0xFFE4472B);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF999999);
const Color _kDark = Color(0xFF050505);

// ── PortfolioRemoveScreen ───────────────────────────────────────────────────
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
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _ctrl.getItems();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load assets';
        });
      }
    }
  }

  Future<void> _removeItem(String id) async {
    final ok = await _ctrl.deleteItem(id);
    if (ok) {
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 22),
              // Header: back button + title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  children: [
                    _BackButton(onTap: () => Navigator.pop(context)),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Portfolio',
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
              const SizedBox(height: 30),
              // ── Section container ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: _kSectionBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _EditPortfolioTab(),
                      ListenableBuilder(
                        listenable: CurrencyProvider(),
                        builder: (context, _) {
                          if (_loading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(color: _kRed),
                              ),
                            );
                          }
                          if (_error != null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                          if (_items.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'ยังไม่มีสินทรัพย์ในพอร์ต',
                                  style: TextStyle(color: _kGray),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AssetTransactionCard(
                                  item: item,
                                  onRemove: () => _confirmRemove(item),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRemove(dynamic item) {
    final assetName = item['assetLabel'] ?? item['assetId'] ?? 'Unknown';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kInputBg,
        title: Text('Confirm Deletion', style: GoogleFonts.inter(color: _kWhite)),
        content: Text(
          'Are you sure you want to remove $assetName from your portfolio?',
          style: GoogleFonts.inter(color: _kGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeItem(item['id'].toString());
            },
            child: const Text('Delete', style: TextStyle(color: _kRed)),
          ),
        ],
      ),
    );
  }
}

// ─── Asset Transaction Card ──────────────────────────────────────────────────
class _AssetTransactionCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRemove;

  const _AssetTransactionCard({required this.item, required this.onRemove});

  double _toDouble(dynamic v) =>
      (v is num) ? v.toDouble() : (double.tryParse(v.toString()) ?? 0.0);

  @override
  Widget build(BuildContext context) {
    final name = item['assetLabel'] ?? item['assetId'] ?? 'Asset';
    final symbol = item['assetId'] ?? '';
    final qty = _toDouble(item['quantity']);
    final price = _toDouble(item['buyPrice']);
    final date = item['buyDate'] ?? '-';
    final currency = CurrencyProvider();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kInputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kRed.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        AssetHelper.getAssetImagePath(symbol),
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 20,
                          height: 20,
                          color: const Color(0xFF282828),
                          child: Center(
                            child: Text(
                              symbol.isNotEmpty ? symbol[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kWhite,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($symbol)',
                      style: GoogleFonts.inter(fontSize: 12, color: _kGray),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoRow('Qty', 'x${qty.toStringAsFixed(4)}'),
                    _InfoRow('Price', currency.formatValue(price)),
                    _InfoRow('Date', date),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(8),
              hoverColor: _kRed.withValues(alpha: 0.25),
              splashColor: _kRed.withValues(alpha: 0.35),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/remove.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    _kRed,
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

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: _kGray)),
        Text(value, style: GoogleFonts.inter(fontSize: 12, color: _kWhite)),
      ],
    );
  }
}

// ─── Edit Portfolio Tab ───────────────────────────────────────────────────────
class _EditPortfolioTab extends StatelessWidget {
  const _EditPortfolioTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
        Text(
          'Edit Portfolio',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _kRed,
          ),
        ),
        const SizedBox(height: 10),
        Container(height: 1.5, color: _kRed),
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
          ),
        ),
      ),
    );
  }
}
