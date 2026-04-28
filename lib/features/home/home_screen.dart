import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../../core/currency_provider.dart';
import '../portfolio/portfolio_controller.dart';
import '../portfolio/portfolioadd_screen.dart';
import '../portfolio/portfolioremove_screen.dart';
import '../nagbar/app_shell.dart';
import '../trend/market_controller.dart';
import '../chat/ai_controller.dart';
import '../../core/asset_helper.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF191919);
const Color _kDarkCard = Color(0xFF282828);
const Color _kRed = Color(0xFFE4472B);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF595959);
const Color _kDivider = Color(0xFF1F1F1F);
const Color _kWhite80 = Color(0xCCFFFFFF);
const Color _kWhite50 = Color(0x80FFFFFF);
const Color _kNotifDot = Color(0xFFDB2110);
const Color _kCardBorder = Color(0xFF282828);

// ═══════════════════════════════════════════════════════════════════════════════
// HomeScreen
// ═══════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MarketController _marketCtrl = MarketController();
  final AiController _aiCtrl = AiController();

  List<Map<String, dynamic>> _marketAssets = [];
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = true;
  bool _isPredictionsLoading = true;
  int _predictionsLimit = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isPredictionsLoading = true;
    });

    // Load market assets (fast)
    final assets = await _marketCtrl.getMarketAssets();
    if (mounted) {
      setState(() {
        _marketAssets = assets;
        _isLoading = false;
      });
    }

    // Load latest predictions (Unified feed)
    final latestPredictions = await _aiCtrl.getLatestPredictions(
      limit: _predictionsLimit,
    );

    if (mounted) {
      setState(() {
        _predictions = latestPredictions;
        _isPredictionsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show all available assets in cards
    final topAssets = _marketAssets;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: _kRed,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                // ── App Bar ───────────────────────────────────────────────────
                const _HomeAppBar(),
                const SizedBox(height: 15),

                // ── Crypto Cards ──────────────────────────────────────────────
                if (_isLoading)
                  const SizedBox(
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(color: _kRed),
                    ),
                  )
                else
                  _CryptoCardsList(assets: topAssets),

                const SizedBox(height: 12),

                // ── AI Predictions ───────────────────────────────────────────
                const _SectionDivider(label: 'AI Predictions'),
                const SizedBox(height: 16),
                if (_isPredictionsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: _kRed),
                    ),
                  )
                else if (_predictions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'ไม่พบข้อมูลการพยากรณ์',
                        style: GoogleFonts.inter(
                          color: _kWhite50,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ..._predictions.map((p) => _PredictionItem(prediction: p)),

                // Show more / Show less
                if (_predictions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 24,
                      top: 10,
                      bottom: 16,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _InteractiveTextButton(
                        label: _predictionsLimit == 5 ? 'Show more' : 'Show less',
                        onTap: () {
                          setState(() {
                            _predictionsLimit = (_predictionsLimit == 5) ? 10 : 5;
                          });
                          _loadData();
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // ── Portfolio Summary ─────────────────────────────────────────
                const _SectionDivider(label: 'Portfolio Summary'),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _PortfolioCard(),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _HomeAppBar
// ═══════════════════════════════════════════════════════════════════════════════
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
            ],
          ),
          // Bell icon with red notification dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/notification_icon.png',
                    width: 18,
                    height: 18,
                    color: _kWhite,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _kNotifDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _CryptoCardsList
// ═══════════════════════════════════════════════════════════════════════════════
class _CryptoCardsList extends StatelessWidget {
  final List<Map<String, dynamic>> assets;
  const _CryptoCardsList({required this.assets});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: Text(
            'ไม่มีข้อมูลสินทรัพย์',
            style: TextStyle(color: Colors.white24),
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          itemCount: assets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) => _CryptoCard(asset: assets[index]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _CryptoCard
// ═══════════════════════════════════════════════════════════════════════════════
class _CryptoCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  const _CryptoCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        screenWidth * 0.6; // Smaller width to show hint of next card

    final name = asset['name'] ?? 'Unknown';
    final symbol = asset['symbol'] ?? '';
    final priceTHB = (asset['thbValue'] as num?)?.toDouble() ?? 0.0;
    final changePercent = (asset['changePercent'] as num?)?.toDouble() ?? 0.0;
    final isPositive = changePercent >= 0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      builder: (context, value, child) {
        final pulse =
            (math.sin(DateTime.now().millisecondsSinceEpoch / 1000 * math.pi) +
                1) /
            2;

        return Container(
          width: cardWidth,
          height: 200,
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: (isPositive ? _kGreen : _kRed).withOpacity(
                  0.08 + (pulse * 0.12),
                ),
                blurRadius: 10 + (pulse * 5),
                spreadRadius: 1 + (pulse * 1),
              ),
            ],
            border: Border.all(
              color: (isPositive ? _kGreen : _kRed).withOpacity(
                0.15 + (pulse * 0.25),
              ),
              width: 1.2,
            ),
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 10, top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child:
                      AssetHelper.isSvg(AssetHelper.getAssetImagePath(symbol))
                      ? SvgPicture.asset(
                          AssetHelper.getAssetImagePath(symbol),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          placeholderBuilder: (context) => Container(
                            width: 44,
                            height: 44,
                            color: _kDarkCard,
                            child: const Icon(
                              Icons.show_chart,
                              color: Colors.white24,
                              size: 20,
                            ),
                          ),
                        )
                      : Image.asset(
                          AssetHelper.getAssetImagePath(symbol),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 44,
                                height: 44,
                                color: _kDarkCard,
                                child: const Icon(
                                  Icons.show_chart,
                                  color: Colors.white24,
                                  size: 20,
                                ),
                              ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$name ($symbol)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _kWhite,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      ListenableBuilder(
                        listenable: CurrencyProvider(),
                        builder: (context, _) {
                          return Text(
                            CurrencyProvider().formatValue(priceTHB),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: _kWhite,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _kDarkCard,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.north_east_rounded,
                    size: 12,
                    color: _kWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Real daily sparkline from AI API
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _RealSparkline(
                        symbol: symbol,
                        isPositive: isPositive,
                      ),
                    ),
                  ),
                  // Percentage Badge (Optional overlay)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Text(
                      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: (isPositive ? _kGreen : _kRed).withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _SectionDivider
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: _kDivider)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.golosText(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kGray,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: _kDivider)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PredictionItem
// ═══════════════════════════════════════════════════════════════════════════════
class _PredictionItem extends StatelessWidget {
  final Map<String, dynamic> prediction;
  const _PredictionItem({required this.prediction});

  @override
  Widget build(BuildContext context) {
    // Mapping from Unified API keys
    final symbol = prediction['market'] ?? prediction['symbol'] ?? '';
    final trend =
        prediction['trend_regime'] ?? prediction['overallTrend'] ?? 'neutral';
    final signal = prediction['signal_action'] ?? 'WAIT';
    final timeRaw = prediction['date'] ?? prediction['predictedAt'] as String?;
    final price =
        (prediction['price'] ?? prediction['currentPrice'] as num?)
            ?.toDouble() ??
        0.0;

    // Format time: dd/MM/yyyy HH:mm
    String time = '--/--/---- --:--';
    if (timeRaw != null) {
      try {
        final dt = DateTime.parse(timeRaw).toLocal();
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final year = dt.year.toString();
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        time = '$day/$month/$year $hour:$minute';
      } catch (_) {}
    }

    final isUptrend =
        trend.toLowerCase().contains('uptrend') ||
        trend.toLowerCase().contains('bullish');
    final isDowntrend =
        trend.toLowerCase().contains('downtrend') ||
        trend.toLowerCase().contains('bearish');
    final trendLabel = isUptrend
        ? 'Uptrend'
        : (isDowntrend ? 'Downtrend' : 'Neutral');

    final isBuy = signal.toUpperCase() == 'BUY';
    final isSell = signal.toUpperCase() == 'SELL';
    final signalColor = isBuy ? _kGreen : (isSell ? _kRed : _kWhite);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Row(
        children: [
          // Coin icon
          ClipOval(
            child: AssetHelper.isSvg(AssetHelper.getAssetImagePath(symbol))
                ? SvgPicture.asset(
                    AssetHelper.getAssetImagePath(symbol),
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    placeholderBuilder: (context) => Container(
                      width: 30,
                      height: 30,
                      color: _kDarkCard,
                      child: const Icon(
                        Icons.show_chart,
                        color: Colors.white24,
                        size: 15,
                      ),
                    ),
                  )
                : Image.asset(
                    AssetHelper.getAssetImagePath(symbol),
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 30,
                      height: 30,
                      color: _kDarkCard,
                      child: const Icon(
                        Icons.show_chart,
                        color: Colors.white24,
                        size: 15,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Signal Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: signalColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: signalColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        signal,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: signalColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trendLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _kWhite80,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: _kWhite50,
                  ),
                ),
              ],
            ),
          ),
          // Price
          ListenableBuilder(
            listenable: CurrencyProvider(),
            builder: (context, _) {
              return Text(
                CurrencyProvider().formatValue(price),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _kWhite,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PortfolioCard
// ═══════════════════════════════════════════════════════════════════════════════
class _PortfolioCard extends StatefulWidget {
  const _PortfolioCard();

  @override
  State<_PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<_PortfolioCard> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await PortfolioController().getPortfolioData();
    if (mounted) {
      setState(() {
        _summary = data?['summary'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: _kRed)),
      );
    }

    final totalCost = (_summary?['totalCost'] as num?)?.toDouble() ?? 0.0;
    final currentValue = (_summary?['currentValue'] as num?)?.toDouble() ?? 0.0;
    final totalProfit = (_summary?['totalProfit'] as num?)?.toDouble() ?? 0.0;
    final profitPercent =
        (_summary?['totalProfitPercent'] as num?)?.toDouble() ?? 0.0;

    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final isPositive = totalProfit >= 0;

        return Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row: Current Balance label + Currency badge ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Balance',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _kWhite80,
                    ),
                  ),
                  const SizedBox.shrink(), // ลบ Badge ออก
                ],
              ),
              const SizedBox(height: 8),
              // ── Balance value + % indicator ─────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    CurrencyProvider().formatValue(currentValue),
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: _kWhite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const SizedBox(width: 2),
                      Text(
                        '${isPositive ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isPositive ? _kGreen : _kRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ── Invested Balance | Total Profit ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invested Balance',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _kWhite80,
                    ),
                  ),
                  Text(
                    'Total Profit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _kWhite80,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyProvider().formatValue(totalCost),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _kWhite,
                    ),
                  ),
                  Row(
                    children: [
                      Transform.rotate(angle: isPositive ? 0 : math.pi),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyProvider().formatValue(
                          totalProfit,
                          signed: true,
                          includeSymbol: true,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? _kGreen : _kRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // ── Action buttons ──────────────────────────────────────────────
              Row(
                children: [
                  _ActionButton(
                    iconPath: 'assets/icons/add.svg',
                    label: 'Add',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PortfolioAddScreen(),
                        ),
                      ).then((_) => _fetchData());
                    },
                  ),
                  const SizedBox(width: 15),
                  _ActionButton(
                    iconPath: 'assets/icons/remove.svg',
                    label: 'Remove',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PortfolioRemoveScreen(),
                        ),
                      ).then((_) => _fetchData());
                    },
                  ),
                  const SizedBox(width: 15),
                  _ActionButton(
                    iconPath: 'assets/icons/assets.svg',
                    label: 'Assets',
                    onTap: () {
                      AppShell.appShellKey.currentState?.setSelectedIndex(2);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _ActionButton
// ═══════════════════════════════════════════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: _kDarkCard,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 25,
                height: 25,
                colorFilter: const ColorFilter.mode(_kWhite, BlendMode.srcIn),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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

// ═══════════════════════════════════════════════════════════════════════════════
// _RealSparkline — fetches daily price history from AI API & draws real chart
// ═══════════════════════════════════════════════════════════════════════════════

/// Maps a frontend asset symbol to the AI backend market key.
String? _toAiMarket(String symbol) {
  final s = symbol.toUpperCase();
  if (s == 'BTC' || s.contains('BTC')) return 'BTC';
  if (s == 'GOLD' || s.contains('XAU') || s.contains('GOLD')) return 'Gold';
  if (s.contains('SET') || s == 'THAI') return 'Thai';
  if (s == 'UK' || s.contains('UK') || s.contains('FTSE')) return 'UK';
  if (s == 'US' || s.contains('SP') || s.contains('US')) return 'US';
  return null;
}

class _RealSparkline extends StatefulWidget {
  final String symbol;
  final bool isPositive;
  const _RealSparkline({required this.symbol, required this.isPositive});

  @override
  State<_RealSparkline> createState() => _RealSparklineState();
}

class _RealSparklineState extends State<_RealSparkline> {
  List<double> _prices = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  @override
  void didUpdateWidget(_RealSparkline old) {
    super.didUpdateWidget(old);
    if (old.symbol != widget.symbol) _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    final market = _toAiMarket(widget.symbol);
    if (market == null) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 8),
      ));
      final res = await dio.get(
        'http://localhost:8000/api/data',
        queryParameters: {'market': market},
      );
      if (res.statusCode == 200) {
        final history = (res.data['history'] as List?) ?? [];
        final prices = history
            .map((row) => (row['price'] as num?)?.toDouble() ?? 0.0)
            .where((p) => p > 0)
            .toList();
        if (mounted) setState(() { _prices = prices; _loaded = true; });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isPositive ? _kGreen : _kRed;

    // Fallback to original fake sparkline if no data
    if (!_loaded) return const SizedBox.shrink();
    if (_prices.isEmpty) {
      return CustomPaint(
        size: Size.infinite,
        painter: _FakeSparklinePainter(color: color, isPositive: widget.isPositive),
      );
    }

    return CustomPaint(
      size: Size.infinite,
      painter: _RealSparklinePainter(prices: _prices, color: color),
    );
  }
}

// ─── Painter: draws real daily price line + gradient fill ───
class _RealSparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color color;
  const _RealSparklinePainter({required this.prices, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;
    final minP = prices.reduce(math.min);
    final maxP = prices.reduce(math.max);
    final range = maxP - minP == 0 ? 1.0 : maxP - minP;
    final n = prices.length;
    final w = size.width;
    final h = size.height;

    double xOf(int i) => (i / (n - 1)) * w;
    double yOf(double p) => h - ((p - minP) / range) * h * 0.85 - h * 0.05;

    final path = Path();
    path.moveTo(xOf(0), yOf(prices[0]));
    for (int i = 1; i < n; i++) {
      final xc = (xOf(i) + xOf(i - 1)) / 2;
      final yc = (yOf(prices[i]) + yOf(prices[i - 1])) / 2;
      path.quadraticBezierTo(xOf(i - 1), yOf(prices[i - 1]), xc, yc);
    }
    path.lineTo(xOf(n - 1), yOf(prices[n - 1]));

    // Gradient fill under line
    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Price line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RealSparklinePainter old) =>
      old.prices.length != prices.length;
}

// ─── Fallback: original fake sparkline (when AI API not available) ───
class _FakeSparklinePainter extends CustomPainter {
  final Color color;
  final bool isPositive;
  _FakeSparklinePainter({required this.color, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final points = <Offset>[];
    const steps = 10;
    for (int i = 0; i <= steps; i++) {
      double x = (width / steps) * i;
      double baseLine = height / 2;
      double targetY = isPositive ? height * 0.2 : height * 0.8;
      double progress = i / steps;
      double y = baseLine + (targetY - baseLine) * progress;
      double noise = (i % 2 == 0 ? 5.0 : -5.0) * (1 - progress);
      if (i == 0 || i == steps) noise = 0;
      points.add(Offset(x, y + noise));
    }
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final xc = (points[i].dx + points[i - 1].dx) / 2;
      final yc = (points[i].dy + points[i - 1].dy) / 2;
      path.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, xc, yc);
    }
    path.lineTo(points.last.dx, points.last.dy);
    final fillPath = Path.from(path)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, width, height)),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// ═══════════════════════════════════════════════════════════════════════════════
// _InteractiveTextButton
// ═══════════════════════════════════════════════════════════════════════════════
class _InteractiveTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _InteractiveTextButton({required this.label, required this.onTap});

  @override
  State<_InteractiveTextButton> createState() => _InteractiveTextButtonState();
}

class _InteractiveTextButtonState extends State<_InteractiveTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _kRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kRed,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                widget.label == 'Show more'
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                size: 16,
                color: _kRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
