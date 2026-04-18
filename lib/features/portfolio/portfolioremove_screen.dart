import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'portfolio_controller.dart';
import '../../core/currency_provider.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kSectionBg = Color(0xFF000000);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Portfolio',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: _kWhite,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                color: _kSectionBg,
                child: Column(
                  children: [
                    const _EditPortfolioTab(),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: CurrencyProvider(),
                        builder: (context, _) {
                          if (_loading) {
                            return const Center(child: CircularProgressIndicator(color: _kRed));
                          }
                          if (_error != null) {
                            return Center(child: Text(_error!, style: const TextStyle(color: Colors.white)));
                          }
                          if (_items.isEmpty) {
                            return const Center(
                              child: Text('ยังไม่มีสินทรัพย์ในพอร์ต', style: TextStyle(color: _kGray)),
                            );
                          }
                          return ListView.builder(
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

  void _confirmRemove(dynamic item) {
    final assetName = item['assetLabel'] ?? item['assetId'] ?? 'Unknown';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kInputBg,
        title: Text('ยืนยันหน้าลบ', style: GoogleFonts.inter(color: _kWhite)),
        content: Text('คุณต้องการลบ $assetName ในพอร์ตหรือไม่?', style: GoogleFonts.inter(color: _kGray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก', style: TextStyle(color: _kGray))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeItem(item['id'].toString());
            },
            child: const Text('ลบ', style: TextStyle(color: _kRed)),
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

  double _toDouble(dynamic v) => (v is num) ? v.toDouble() : (double.tryParse(v.toString()) ?? 0.0);

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
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _kWhite)),
                    const SizedBox(width: 8),
                    Text('($symbol)', style: GoogleFonts.inter(fontSize: 12, color: _kGray)),
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: _kRed),
            onPressed: onRemove,
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
