import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'portfolioadd_screen.dart';
import 'portfolioremove_screen.dart';
import 'portfolio_controller.dart';
import '../../core/currency_provider.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF191919);
const Color _kBtn = Color(0xFF282828);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kRed = Color(0xFFE4472B);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite80 = Color(0xCCFFFFFF);
const Color _kGray = Color(0xFF595959);
const Color _kDivider = Color(0xFF1F1F1F);

// ─── Screen ───────────────────────────────────────────────────────────────────
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _ctrl = PortfolioController();
  List<dynamic> _items = [];
  double _totalValue = 0;
  double _invested = 0;
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
      final stats = data['stats'] ?? {};
      setState(() {
        _items = data['history'] ?? [];
        _totalValue = _toDouble(stats['totalValue']);
        _invested = _toDouble(stats['invested']);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'โหลดข้อมูลไม่สำเร็จ';
        _loading = false;
      });
    }
  }

  double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;

  @override
  Widget build(BuildContext context) {
    double profit = _totalValue - _invested;
    double percent = _invested > 0 ? (profit / _invested) * 100 : 0;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Portfolio',
              style: GoogleFonts.inter(fontSize: 24, color: _kWhite),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _kRed))
                  : _error != null
                      ? _errorState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: _body(profit, percent),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: _kWhite80)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(backgroundColor: _kRed),
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );

  Widget _body(double profit, double percent) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: _BalanceCard(
              total: _totalValue,
              invested: _invested,
              profit: profit,
              percent: percent,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 33),
            child: _ActionRow(
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PortfolioAddScreen()),
                );
                _load();
              },
              onRemove: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PortfolioRemoveScreen()),
                );
                if (refresh == true) _load();
              },
            ),
          ),
          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 8),
          if (_items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('ยังไม่มีสินทรัพย์\nกด Add เพื่อเพิ่ม',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _kWhite80, height: 1.6)),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  for (int i = 0; i < _items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 5),
                    _AssetItem(
                      item: _items[i],
                      onDelete: () async {
                        final id = _items[i]['id'];
                        if (id != null) {
                          await _ctrl.deleteItem(id.toString());
                          _load();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(child: Container(height: 1, color: _kDivider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text('Assets',
                  style: GoogleFonts.golosText(
                      fontSize: 14, fontWeight: FontWeight.w500, color: _kGray)),
            ),
            Expanded(child: Container(height: 1, color: _kDivider)),
          ],
        ),
      );
}

class _BalanceCard extends StatelessWidget {
  final double total, invested, profit, percent;
  const _BalanceCard({
    required this.total,
    required this.invested,
    required this.profit,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final pos = profit >= 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 18, 24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Current Balance',
                  style:
                      GoogleFonts.inter(fontSize: 16, color: _kWhite80)),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await CurrencyProvider().toggleCurrency();
                  (context as Element).markNeedsBuild();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: _kGray, width: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    CurrencyProvider().currentCurrency,
                    style: GoogleFonts.inter(fontSize: 15, color: _kWhite),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                CurrencyProvider().formatValue(total),
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _kWhite),
              ),
              const SizedBox(width: 15),
              Text(
                '${pos ? '+' : ''}${percent.toStringAsFixed(2)}%',
                style: GoogleFonts.inter(
                    fontSize: 12, color: pos ? _kGreen : _kRed),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invested Balance',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _kWhite80)),
                  const SizedBox(height: 4),
                  Text(CurrencyProvider().formatValue(invested),
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _kWhite)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total Profit',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _kWhite80)),
                  const SizedBox(height: 4),
                  Text(
                      '${pos ? '+' : ''}${CurrencyProvider().formatValue(profit)}',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: pos ? _kGreen : _kRed)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onAdd, onRemove;
  const _ActionRow({required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child: _Btn(
                  icon: 'assets/images/add_icon.png',
                  label: 'Add',
                  onTap: onAdd)),
          const SizedBox(width: 22),
          Expanded(
              child: _Btn(
                  icon: 'assets/images/remove_icon.png',
                  label: 'Remove',
                  onTap: onRemove)),
          const SizedBox(width: 22),
          Expanded(
              child: _Btn(
                  icon: 'assets/images/assets_icon.png',
                  label: 'Assets',
                  onTap: () {})),
        ],
      );
}

class _Btn extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
              color: _kBtn, borderRadius: BorderRadius.circular(5)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 25, height: 25),
              const SizedBox(height: 8),
              Text(label,
                  style: GoogleFonts.inter(fontSize: 12, color: _kWhite)),
            ],
          ),
        ),
      );
}

class _AssetItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onDelete;
  const _AssetItem({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = item['assetLabel'] as String? ?? item['assetId'] as String? ?? 'Unknown';
    final symbol = item['assetId'] as String? ?? '';
    final qty = double.tryParse(item['quantity']?.toString() ?? '0') ?? 0.0;
    final value = double.tryParse(item['currentValue']?.toString() ?? '0') ?? 0.0;
    final profit = double.tryParse(item['profit']?.toString() ?? '0') ?? 0.0;
    final pos = profit >= 0;

    return GestureDetector(
      onLongPress: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _kCard,
          title: const Text('ลบสินทรัพย์', style: TextStyle(color: _kWhite)),
          content: Text('ลบ $name หรือไม่?', style: const TextStyle(color: _kWhite80)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: const Text('ลบ', style: TextStyle(color: _kRed))),
          ],
        ),
      ),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _kDivider)),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(color: _kBtn, shape: BoxShape.circle),
              child: Center(
                  child: Text(symbol.isNotEmpty ? symbol[0] : '?',
                      style: const TextStyle(color: _kWhite, fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: GoogleFonts.inter(fontSize: 16, color: _kWhite)),
                  Text('x$qty', style: GoogleFonts.inter(fontSize: 14, color: _kWhite80)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(CurrencyProvider().formatValue(value),
                    style: GoogleFonts.inter(fontSize: 15, color: _kWhite)),
                Text('${pos ? '+' : ''}${CurrencyProvider().formatValue(profit)}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: pos ? _kGreen : _kRed)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
