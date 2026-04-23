import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/currency_provider.dart';
import 'market_controller.dart';
import '../../core/asset_helper.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF191919);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite80 = Color(0xCCFFFFFF); // rgba(255,255,255,0.80)


// ═══════════════════════════════════════════════════════════════════════════════
// MarketScreen
// ═══════════════════════════════════════════════════════════════════════════════

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketController _marketCtrl = MarketController();
  List<Map<String, dynamic>> _assets = [];
  bool _isLoading = true;
  String _selectedTimeframe = '1D';

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    setState(() => _isLoading = true);
    final data = await _marketCtrl.getMarketAssets();
    if (mounted) {
      setState(() {
        _assets = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title ──────────────────────────────────────────────────────
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Market',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _kWhite,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Timeframe Filter ───────────────────────────────────────────
            _buildTimeframeFilter(),
            const SizedBox(height: 20),

            // ── Coin List ──────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE0543D)))
                  : RefreshIndicator(
                      onRefresh: _fetchAssets,
                      color: const Color(0xFFE0543D),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _assets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          final asset = _assets[index];
                          return _CoinCard(
                            asset: asset,
                            timeframe: _selectedTimeframe,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 36,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['1D', '7D', '30D'].map((tf) {
          final isSelected = _selectedTimeframe == tf;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeframe = tf),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE4472B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tf,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? _kWhite : _kWhite.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Coin Card ────────────────────────────────────────────────────────────────
class _CoinCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final String timeframe;

  const _CoinCard({required this.asset, required this.timeframe});

  @override
  Widget build(BuildContext context) {
    final name = asset['name'] ?? 'Unknown';
    final symbol = asset['symbol'] ?? '';
    final priceTHB = (asset['thbValue'] as num?)?.toDouble() ?? 0.0;
    
    // Select percentage based on timeframe
    double changePercent = 0.0;
    if (timeframe == '1D') {
      changePercent = (asset['change1D'] as num?)?.toDouble() ?? 0.0;
    } else if (timeframe == '7D') {
      changePercent = (asset['change7D'] as num?)?.toDouble() ?? 0.0;
    } else if (timeframe == '30D') {
      changePercent = (asset['change30D'] as num?)?.toDouble() ?? 0.0;
    }

    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final currency = CurrencyProvider();
        final price = currency.formatValue(priceTHB);
        final isPositive = changePercent >= 0;
        final changeStr =
            '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
        final changeColor = isPositive ? _kGreen : const Color(0xFFE4472B);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF191919),
                Color(0xFF666666),
              ],
            ),
          ),
          child: Container(
            height: 80,
            margin: const EdgeInsets.all(1.2),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(4.5),
            ),
          child: Row(
            children: [
              // ── Coin Icon ────────────────────────────────────────────────
              ClipOval(
                child: Image.asset(
                  AssetHelper.getAssetImagePath(symbol),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: _kCard,
                    child: const Icon(Icons.show_chart, color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Name + Ticker ─────────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: _kWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    symbol,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: _kWhite80,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Price + Change % ──────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    changeStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}
