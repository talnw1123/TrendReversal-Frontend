import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/currency_provider.dart';
import 'market_controller.dart';
import '../../core/asset_helper.dart';
import 'trend_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF0F0F0F); // Slightly darker background
const Color _kCard = Color(0xFF1A1A1A);
const Color _kGreen = Color(0xFF47D5A6); // Updated to user's preferred green
const Color _kRed = Color(0xFFE4472B);   // Matched with HomeScreen red
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite80 = Color(0xCCFFFFFF);
const Color _kAccent = Color(0xFFE0543D); // Primary brand color


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
    final timeframes = ['1D', '7D', '30D'];
    final selectedIndex = timeframes.indexOf(_selectedTimeframe);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 44,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          // Sliding Background
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutQuart,
            alignment: Alignment(
              -1.0 + (selectedIndex * (2.0 / (timeframes.length - 1))),
              0.0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / timeframes.length,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _kAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Labels Row
          Row(
            children: timeframes.map((tf) {
              final isSelected = _selectedTimeframe == tf;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTimeframe = tf),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? _kWhite : _kWhite.withOpacity(0.5),
                      ),
                      child: Text(tf),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Coin Card ────────────────────────────────────────────────────────────────
class _CoinCard extends StatefulWidget {
  final Map<String, dynamic> asset;
  final String timeframe;

  const _CoinCard({required this.asset, required this.timeframe});

  @override
  State<_CoinCard> createState() => _CoinCardState();
}

class _CoinCardState extends State<_CoinCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _borderCtrl;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _borderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void dispose() {
    _borderCtrl.dispose();
    super.dispose();
  }

  void _onTap(bool isPositive) async {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);
    _borderCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 750));
    if (mounted) {
      final asset = widget.asset;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrendScreen(
            assetName: asset['name'] ?? 'Unknown',
            assetSymbol: asset['symbol'] ?? '',
            assetPrice: (asset['thbValue'] as num?)?.toDouble() ?? 0.0,
            assetChange1D: (asset['change1D'] as num?)?.toDouble() ?? 0.0,
          ),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _isAnimating = false);
      _borderCtrl.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final name = asset['name'] ?? 'Unknown';
    final symbol = asset['symbol'] ?? '';
    final priceTHB = (asset['thbValue'] as num?)?.toDouble() ?? 0.0;

    double changePercent = 0.0;
    String timeframeLabel = '';

    if (widget.timeframe == '1D') {
      changePercent = (asset['change1D'] as num?)?.toDouble() ?? 0.0;
      timeframeLabel = 'Per Day';
    } else if (widget.timeframe == '7D') {
      changePercent = (asset['change7D'] as num?)?.toDouble() ?? 0.0;
      timeframeLabel = 'Per Week';
    } else if (widget.timeframe == '30D') {
      changePercent = (asset['change30D'] as num?)?.toDouble() ?? 0.0;
      timeframeLabel = 'Per Month';
    }

    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final currency = CurrencyProvider();
        final price = currency.formatValue(priceTHB);
        final isPositive = changePercent >= 0;
        final changeStr =
            '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
        final changeColor = isPositive ? _kGreen : _kRed;
        final borderColor = isPositive ? _kGreen : _kRed;

        return GestureDetector(
          onTap: () => _onTap(isPositive),
          child: AnimatedBuilder(
            animation: _borderCtrl,
            builder: (context, child) {
              return CustomPaint(
                painter: _isAnimating
                    ? _RunningBorderPainter(
                        progress: _borderCtrl.value,
                        color: borderColor,
                        borderRadius: 16,
                        strokeWidth: 2.5,
                      )
                    : null,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isPositive ? _kGreen.withOpacity(0.6) : _kRed.withOpacity(0.6),
                    Colors.white.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Container(
                height: 90,
                margin: const EdgeInsets.all(1.2),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    // ── Coin Icon ────────────────────────────────────────────────
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: AssetHelper.isSvg(AssetHelper.getAssetImagePath(symbol))
                            ? SvgPicture.asset(
                                AssetHelper.getAssetImagePath(symbol),
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                placeholderBuilder: (context) => Container(
                                  width: 52,
                                  height: 52,
                                  color: _kCard,
                                  child: const Icon(Icons.show_chart, color: Colors.white24),
                                ),
                              )
                            : Image.asset(
                                AssetHelper.getAssetImagePath(symbol),
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 52,
                                  height: 52,
                                  color: _kCard,
                                  child: const Icon(Icons.show_chart, color: Colors.white24),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // ── Name + Ticker ─────────────────────────────────────────────
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _kWhite,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              symbol,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kWhite80,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Price + Change % ──────────────────────────────────────────
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _kWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              changeStr,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: changeColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeframeLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: _kWhite.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Running Border Painter ───────────────────────────────────────────────────
class _RunningBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderRadius;
  final double strokeWidth;

  const _RunningBorderPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;

    // Arc length: 40% of perimeter sweeping across
    const sweepFraction = 0.40;
    final sweepLength = totalLength * sweepFraction;
    final startLength = totalLength * progress;

    final extractPath = pathMetrics.extractPath(
      startLength,
      startLength + sweepLength,
    );

    // Wrap-around
    if (startLength + sweepLength > totalLength) {
      final overflow = startLength + sweepLength - totalLength;
      final wrapPath = pathMetrics.extractPath(0, overflow);
      extractPath.addPath(wrapPath, Offset.zero);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.8);

    // Glow pass
    canvas.drawPath(extractPath, paint);

    // Sharp pass
    canvas.drawPath(
      extractPath,
      paint
        ..maskFilter = null
        ..color = color.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(_RunningBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

