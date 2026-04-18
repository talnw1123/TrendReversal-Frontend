import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'portfolio_controller.dart';
import 'portfolioadd_screen.dart';
import 'portfolioremove_screen.dart';
import '../../core/currency_provider.dart';
import '../../shared/widgets/currency_toggle.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg     = Color(0xFF121212);
const Color _kCard   = Color(0xFF191919);
const Color _kBtn    = Color(0xFF282828);
const Color _kGreen  = Color(0xFF47D5A6);
const Color _kRed    = Color(0xFFE4472B);
const Color _kWhite  = Color(0xFFFFFFFF);
const Color _kWhite80 = Color(0xCCFFFFFF);
const Color _kGray   = Color(0xFF595959);
const Color _kDivider = Color(0xFF1F1F1F);

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PortfolioScreen
// ═══════════════════════════════════════════════════════════════════════════════
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _ctrl = PortfolioController();

  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  double _totalValue = 0;
  double _invested   = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    // Fetch exchange rate
    final rate = await _ctrl.getUsdRate();
    if (rate != null) CurrencyProvider().setUsdRate(rate);
    
    // Fetch portfolio data
    final data = await _ctrl.getPortfolioData();
    if (mounted) {
      if (data != null) {
        final summary = data['summary'] as Map<String, dynamic>?;
        setState(() {
          _items      = data['items'] ?? [];
          _totalValue = _toDouble(summary?['currentValue']);
          _invested   = _toDouble(summary?['totalCost']);
          _loading    = false;
        });
      } else {
        setState(() {
          _items = [];
          _loading = false;
          _error = 'ไม่พบข้อมูล หรือเซสชันหมดอายุ';
        });
      }
    }
  }

  Future<void> _toggleCurrency() async {
    await CurrencyProvider().toggle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profit  = _totalValue - _invested;
    final percent = _invested > 0 ? (profit / _invested) * 100 : 0.0;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: CurrencyProvider(),
          builder: (context, _) => RefreshIndicator(
            onRefresh: _loadAll,
            color: _kGreen,
            backgroundColor: _kCard,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF47D5A6)))
                : _error != null
                    ? _errorState()
                    : _body(profit, percent),
          ),
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
          onPressed: _loadAll,
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
          // Balance card
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
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 33),
            child: _ActionRow(
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PortfolioAddScreen()),
                );
                _loadAll();
              },
              onRemove: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PortfolioRemoveScreen()),
                );
                if (refresh == true) _loadAll();
              },
            ),
          ),
          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 8),
          // List
          if (_items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'ยังไม่มีสินทรัพย์\nกด Add เพื่อเพิ่ม',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kWhite80, height: 1.6),
                ),
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
                          _loadAll();
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
          child: Text('Assets', style: _golo(14, FontWeight.w500, _kGray)),
        ),
        Expanded(child: Container(height: 1, color: _kDivider)),
      ],
    ),
  );
}

// ─── Balance Card ─────────────────────────────────────────────────────────────
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
    final currency = CurrencyProvider();
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
              Text('Current Balance', style: _inter(16, FontWeight.w500, _kWhite80)),
              const Spacer(),
              const CurrencyToggle(),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(currency.formatValue(total), style: _inter(20, FontWeight.w600, _kWhite)),
              const SizedBox(width: 15),
              Text(
                '${pos ? '+' : ''}${percent.toStringAsFixed(2)}%',
                style: _inter(12, FontWeight.w400, pos ? _kGreen : _kRed),
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
                  Text('Invested Balance', style: _inter(12, FontWeight.w500, _kWhite80)),
                  const SizedBox(height: 4),
                  Text(currency.formatValue(invested), style: _inter(15, FontWeight.w600, _kWhite)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total Profit', style: _inter(12, FontWeight.w500, _kWhite80)),
                  const SizedBox(height: 4),
                  Text(
                    '${pos ? '+' : ''}${currency.formatValue(profit)}',
                    style: _inter(15, FontWeight.w600, pos ? _kGreen : _kRed),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _ActionRow({required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: _Btn(icon: 'assets/images/add_icon.png',    label: 'Add',    onTap: onAdd)),
      const SizedBox(width: 22),
      Expanded(child: _Btn(icon: 'assets/images/remove_icon.png', label: 'Remove', onTap: onRemove)),
      const SizedBox(width: 22),
      Expanded(child: _Btn(icon: 'assets/images/assets_icon.png', label: 'Assets', onTap: () {})),
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
      decoration: BoxDecoration(color: _kBtn, borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 25, height: 25),
          const SizedBox(height: 8),
          Text(label, style: _inter(12, FontWeight.w500, _kWhite)),
        ],
      ),
    ),
  );
}

// ─── Asset List Item ──────────────────────────────────────────────────────────
class _AssetItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onDelete;
  const _AssetItem({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name   = item['assetLabel'] as String? ?? item['assetId'] as String? ?? 'Unknown';
    final symbol = item['assetId'] as String? ?? '';
    final qty    = _toDouble(item['quantity']);
    final value  = _toDouble(item['currentValue']);
    final profit = _toDouble(item['profit']);
    final pos    = profit >= 0;
    final currency = CurrencyProvider();

    return GestureDetector(
      onLongPress: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _kCard,
          title: const Text('ลบสินทรัพย์', style: TextStyle(color: _kWhite)),
          content: Text('ต้องการลบ $name ออกจากพอร์ตหรือไม่?', style: const TextStyle(color: _kWhite80)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก', style: TextStyle(color: _kWhite80))),
            TextButton(
              onPressed: () { Navigator.pop(context); onDelete(); },
              child: const Text('ลบ', style: TextStyle(color: _kRed)),
            ),
          ],
        ),
      ),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: _kDivider, width: 0.8),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50, height: 50,
              decoration: const BoxDecoration(color: _kBtn, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  symbol.isNotEmpty ? symbol[0].toUpperCase() : '?',
                  style: const TextStyle(color: _kWhite, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(child: Text(name, style: _inter(16, FontWeight.w500, _kWhite), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 5),
                      Text(symbol, style: _inter(10, FontWeight.w400, _kWhite80)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('x${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 5)}', style: _inter(15, FontWeight.w400, _kWhite80)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(currency.formatValue(value), style: _inter(15, FontWeight.w400, _kWhite)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/up_arrow.svg',
                      width: 8, height: 5,
                      colorFilter: ColorFilter.mode(pos ? _kGreen : _kRed, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pos ? '+' : ''}${currency.formatValue(profit)}',
                      style: _inter(12, FontWeight.w400, pos ? _kGreen : _kRed),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Style Helpers ────────────────────────────────────────────────────────────
TextStyle _inter(double size, FontWeight w, Color c) =>
    TextStyle(fontFamily: 'Inter', fontSize: size, fontWeight: w, color: c);

TextStyle _golo(double size, FontWeight w, Color c) =>
    TextStyle(fontFamily: 'GolosText', fontSize: size, fontWeight: w, color: c);
