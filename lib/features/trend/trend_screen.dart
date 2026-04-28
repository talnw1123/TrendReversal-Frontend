import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/currency_provider.dart';
import '../../core/asset_helper.dart';
import 'trend_controller.dart';
import '../chat/ai_controller.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF282828);
const Color _kCard2 = Color(0xFF1A1A1A);
const Color _kRed = Color(0xFFE4472B);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite50 = Color(0x80FFFFFF);
const Color _kWhite20 = Color(0x33FFFFFF);

// ─── Time Frames ──────────────────────────────────────────────────────────────
const List<String> _kTimeFrames = ['1W', '1M', '3M', '6M', '1Y', 'ALL'];
const int _kDefaultTimeFrame = 1; // '1M'

// ═══════════════════════════════════════════════════════════════════════════════
// TrendScreen
// ═══════════════════════════════════════════════════════════════════════════════
class TrendScreen extends StatefulWidget {
  final String assetName;
  final String assetSymbol;
  final double assetPrice;
  final double assetChange1D;

  const TrendScreen({
    super.key,
    this.assetName = 'Solana',
    this.assetSymbol = 'SOL',
    this.assetPrice = 4340.39,
    this.assetChange1D = 0.50,
  });

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  int _selectedTimeFrame = _kDefaultTimeFrame;
  bool _isUptrend = true;

  bool _isLoading = true;
  List<TrendDataPoint> _history = [];
  TrendStats? _stats;

  List<Map<String, dynamic>> _predictions = [];
  bool _isPredictionsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    setState(() => _isPredictionsLoading = true);
    final all = await AiController().getLatestPredictions(limit: 50);
    // Use the same market-key mapping as TrendController (e.g. XAU/GOLD → 'Gold')
    final marketKey = (TrendController.symbolToMarket(widget.assetSymbol) ??
            widget.assetSymbol)
        .toLowerCase();
    final filtered = all.where((p) {
      final m = ((p['market'] ?? p['symbol'] ?? '') as String).toLowerCase();
      return m == marketKey || m.contains(marketKey) || marketKey.contains(m);
    }).take(10).toList();
    if (mounted) {
      setState(() {
        _predictions = filtered;
        _isPredictionsLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await TrendController().fetchTrendData(widget.assetSymbol);
    if (mounted) {
      setState(() {
        if (data != null) {
          _history = data.history;
          _stats = data.stats;
          _isUptrend = _history.isNotEmpty ? _history.last.isUptrend : true;
        }
        _isLoading = false;
      });
    }
  }

  int get _visiblePoints {
    if (_history.isEmpty) return 2;
    int takeCount = _history.length;
    final tf = _kTimeFrames[_selectedTimeFrame];
    switch (tf) {
      case '1W':
        takeCount = 7;
        break;
      case '1M':
        takeCount = 30;
        break;
      case '3M':
        takeCount = 90;
        break;
      case '6M':
        takeCount = 180;
        break;
      case '1Y':
        takeCount = 365;
        break;
      case 'ALL':
        takeCount = _history.length;
        break;
    }
    return math.min(takeCount, _history.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 22),

              // ── App Bar ──────────────────────────────────────────────────
              _TrendAppBar(
                assetName: widget.assetName,
                assetSymbol: widget.assetSymbol,
              ),
              const SizedBox(height: 20),

              // ── Price ────────────────────────────────────────────────────
              _PriceHeader(price: widget.assetPrice),
              const SizedBox(height: 6),

              // ── After hours row ──────────────────────────────────────────
              _AfterHoursHeader(
                price: widget.assetPrice,
                change1D: widget.assetChange1D,
              ),
              const SizedBox(height: 10),

              // ── Separator ────────────────────────────────────────────────
              Container(height: 2, color: _kWhite20),

              // ── Time frame selector ──────────────────────────────────────
              _TimeFrameSelector(
                selectedIndex: _selectedTimeFrame,
                onSelected: (i) => setState(() => _selectedTimeFrame = i),
              ),

              // ── AI Dynamic Chart ─────────────────────────────────────────
              AspectRatio(
                aspectRatio: 440 / 377,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _kRed),
                      )
                    : _history.isEmpty
                    ? Center(
                        child: Text(
                          'No chart data available for ${widget.assetSymbol}',
                          style: GoogleFonts.inter(color: _kWhite50),
                        ),
                      )
                    : _AiTrendChart(
                        history: _history,
                        isUptrend: _isUptrend,
                        assetSymbol: widget.assetSymbol,
                        visiblePoints: _visiblePoints,
                      ),
              ),
              // ── Performance Stats ─────────────────────────────────────────
              const SizedBox(height: 12),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator(color: _kRed)),
                )
              else if (_stats != null)
                _PerformanceStatsSection(stats: _stats!)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No stats available',
                      style: GoogleFonts.inter(fontSize: 14, color: _kWhite50),
                    ),
                  ),
                ),

              // ── AI Prediction History ──────────────────────────────
              _AiPredictionSection(
                predictions: _predictions,
                isLoading: _isPredictionsLoading,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _TrendAppBar
// ═══════════════════════════════════════════════════════════════════════════════
class _TrendAppBar extends StatelessWidget {
  final String assetName;
  final String assetSymbol;
  const _TrendAppBar({required this.assetName, required this.assetSymbol});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        children: [
          // Back button — identical to PortfolioAdd
          Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(8),
              hoverColor: Colors.white.withOpacity(0.1),
              splashColor: Colors.white.withOpacity(0.05),
              child: Center(
                child: Image.asset(
                  'assets/icons/back_icon.png',
                  width: 20,
                  height: 20,
                  color: _kWhite,
                ),
              ),
            ),
          ),
          // Title centered
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Asset Logo
                  ClipOval(
                    child:
                        AssetHelper.isSvg(
                          AssetHelper.getAssetImagePath(assetSymbol),
                        )
                        ? SvgPicture.asset(
                            AssetHelper.getAssetImagePath(assetSymbol),
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            AssetHelper.getAssetImagePath(assetSymbol),
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$assetName ($assetSymbol)',
                    style: GoogleFonts.golosText(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Spacer to keep title centered
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PriceHeader
// ═══════════════════════════════════════════════════════════════════════════════
class _PriceHeader extends StatelessWidget {
  final double price;
  const _PriceHeader({required this.price});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final currency = CurrencyProvider();
        final formattedPrice = currency.formatValue(price);
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Price
              Text(
                formattedPrice,
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: _kWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _AfterHoursHeader
// ═══════════════════════════════════════════════════════════════════════════════
class _AfterHoursHeader extends StatelessWidget {
  final double price;
  final double change1D;

  const _AfterHoursHeader({required this.price, required this.change1D});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final currency = CurrencyProvider();
        final isPositive = change1D >= 0;
        final changeColor = isPositive ? _kGreen : _kRed;

        // Calculate change value based on price and percentage
        final double changeValue = price - (price / (1 + (change1D / 100)));

        final formattedPrice = currency.formatValue(price);
        final formattedChangeValue = currency.formatValue(
          changeValue.abs(),
          includeSymbol: false,
        );
        final formattedChangePercent =
            '${isPositive ? '+' : ''}${change1D.toStringAsFixed(2)}%';

        final now = DateTime.now();
        final formattedDate = DateFormat('HH:mm dd/MM').format(now);

        final displayPrice =
            '$formattedPrice ${isPositive ? '+' : '-'}$formattedChangeValue $formattedChangePercent';

        return Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            children: [
              Text(
                'After day:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kWhite50,
                ),
              ),
              Text(
                displayPrice,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: changeColor,
                ),
              ),
              Container(width: 1, height: 10, color: _kWhite50),
              Text(
                formattedDate,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kWhite50,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _TimeFrameSelector
// ═══════════════════════════════════════════════════════════════════════════════
class _TimeFrameSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _TimeFrameSelector({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: _kWhite.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // ── Sliding Highlight ──────────────────────────────────────────
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment(
                -1.0 + (selectedIndex * (2.0 / (_kTimeFrames.length - 1))),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / _kTimeFrames.length,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: _kRed.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Buttons ──────────────────────────────────────────────────────
            Row(
              children: List.generate(_kTimeFrames.length, (i) {
                final isSelected = i == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(i),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? _kWhite : _kWhite50,
                        ),
                        child: Text(_kTimeFrames[i]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PerformanceStatsSection  (responsive 2×2 card grid)
// ═══════════════════════════════════════════════════════════════════════════════

class _PerformanceStatsSection extends StatelessWidget {
  final TrendStats stats;
  const _PerformanceStatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 2×2 Grid ─────────────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final cardW = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatCard(
                    width: cardW,
                    label: 'Strategy Return',
                    value: stats.baseReturnPct,
                    iconPath: 'assets/icons/strategyreturn.svg',
                    mode: _StatMode.percentReturn,
                  ),
                  _StatCard(
                    width: cardW,
                    label: 'Buy & Hold',
                    value: stats.bnhReturnPct,
                    iconPath: 'assets/icons/buyhold.svg',
                    mode: _StatMode.percentReturn,
                  ),
                  _StatCard(
                    width: cardW,
                    label: 'Max Drawdown',
                    value: stats.maxDrawdownPct,
                    iconPath: 'assets/icons/maxdrawdown.svg',
                    mode: _StatMode.drawdown,
                  ),
                  _StatCard(
                    width: cardW,
                    label: 'Win Rate',
                    value: stats.winRatePct,
                    iconPath: 'assets/icons/winrate.svg',
                    mode: _StatMode.winRate,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card Mode ───────────────────────────────────────────────────────────
enum _StatMode { percentReturn, drawdown, winRate }

// ─── _StatCard ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final double width;
  final String label;
  final double value;
  final String iconPath;
  final _StatMode mode;

  const _StatCard({
    required this.width,
    required this.label,
    required this.value,
    required this.iconPath,
    required this.mode,
  });

  Color get _valueColor {
    switch (mode) {
      case _StatMode.percentReturn:
        return value >= 0 ? _kGreen : _kRed;
      case _StatMode.drawdown:
        return _kRed;
      case _StatMode.winRate:
        return value >= 50 ? _kGreen : _kRed;
    }
  }

  String get _formattedValue {
    switch (mode) {
      case _StatMode.percentReturn:
        return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';
      case _StatMode.drawdown:
        return '-${value.abs().toStringAsFixed(2)}%';
      case _StatMode.winRate:
        return '${value.toStringAsFixed(1)}%';
    }
  }

  /// Bar fill ratio 0.0–1.0
  double get _barFill {
    switch (mode) {
      case _StatMode.percentReturn:
        // clamp -100% to +100%
        return ((value + 100) / 200).clamp(0.0, 1.0);
      case _StatMode.drawdown:
        return (value.abs() / 100).clamp(0.0, 1.0);
      case _StatMode.winRate:
        return (value / 100).clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _valueColor;
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: _kCard2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label ──────────────────────────────────────────────────
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _kWhite,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Value ──────────────────────────────────────────────────
              Expanded(
                child: Text(
                  _formattedValue,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                iconPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Progress bar ───────────────────────────────────────────
          LayoutBuilder(
            builder: (ctx, c) => Stack(
              children: [
                Container(
                  height: 4,
                  width: c.maxWidth,
                  decoration: BoxDecoration(
                    color: _kWhite,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  height: 4,
                  width: c.maxWidth * _barFill,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.6), color],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _AiTrendChart & _TrendChartPainter
// ═══════════════════════════════════════════════════════════════════════════════

class _AiTrendChart extends StatefulWidget {
  final List<TrendDataPoint> history;
  final bool isUptrend;
  final String assetSymbol;
  final int visiblePoints;

  const _AiTrendChart({
    required this.history,
    required this.isUptrend,
    required this.assetSymbol,
    required this.visiblePoints,
  });

  @override
  State<_AiTrendChart> createState() => _AiTrendChartState();
}

class _AiTrendChartState extends State<_AiTrendChart> {
  Offset? _crosshairPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) return const SizedBox.shrink();

    final color = widget.isUptrend ? _kGreen : _kRed;

    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final currentCurrency = CurrencyProvider().currentCurrency;

        return LayoutBuilder(
          builder: (context, constraints) {
            const rightAxisWidth = 80.0;
            final availableWidth = constraints.maxWidth - rightAxisWidth;

            final safeVisiblePoints = math.max(2, widget.visiblePoints);
            final pointSpacing = availableWidth / (safeVisiblePoints - 1);
            final chartWidth = math.max(
              availableWidth,
              (widget.history.length - 1) * pointSpacing,
            );

            return Stack(
              children: [
                // 1. Scrollable Chart Area
                Positioned.fill(
                  right: rightAxisWidth,
                  child: GestureDetector(
                    onLongPressStart: (details) => setState(
                      () => _crosshairPosition = details.localPosition,
                    ),
                    onLongPressMoveUpdate: (details) => setState(
                      () => _crosshairPosition = details.localPosition,
                    ),
                    onLongPressEnd: (_) =>
                        setState(() => _crosshairPosition = null),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          ui.PointerDeviceKind.touch,
                          ui.PointerDeviceKind.mouse,
                          ui.PointerDeviceKind.trackpad,
                        },
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // Start at right (newest data)
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          width: chartWidth,
                          height: constraints.maxHeight,
                          child: CustomPaint(
                            size: Size(chartWidth, constraints.maxHeight),
                            painter: _TrendChartPainter(
                              history: widget.history,
                              color: color,
                              crosshairPosition: _crosshairPosition,
                              drawRightAxis: false,
                              currency: currentCurrency,
                              assetSymbol: widget.assetSymbol,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Fixed Right Price Axis
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: rightAxisWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _kBg.withOpacity(0.9),
                      border: Border(
                        left: BorderSide(color: _kWhite.withOpacity(0.1)),
                      ),
                    ),
                    child: CustomPaint(
                      size: Size(rightAxisWidth, constraints.maxHeight),
                      painter: _TrendChartPainter(
                        history: widget.history,
                        color: color,
                        crosshairPosition: null,
                        drawRightAxis: true,
                        onlyRightAxis: true,
                        currency: currentCurrency,
                        assetSymbol: widget.assetSymbol,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ); // close LayoutBuilder
      }, // close ListenableBuilder.builder
    ); // close ListenableBuilder
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<TrendDataPoint> history;
  final Color color;
  final Offset? crosshairPosition;
  final bool drawRightAxis;
  final bool onlyRightAxis;
  final String currency;
  final String assetSymbol;

  const _TrendChartPainter({
    required this.history,
    required this.color,
    required this.currency,
    required this.assetSymbol,
    this.crosshairPosition,
    this.drawRightAxis = false,
    this.onlyRightAxis = false,
  });

  double _normalizeToThb(double rawPrice) {
    final s = assetSymbol.toUpperCase();
    if (s.contains('SET') || s == 'THAI') {
      return rawPrice; // Already THB
    }
    // Assume USD base
    return rawPrice * CurrencyProvider().usdRate;
  }

  String _monthName(int m) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final minPrice = history.map((e) => e.price).reduce(math.min);
    final maxPrice = history.map((e) => e.price).reduce(math.max);
    final range = maxPrice - minPrice == 0 ? 1.0 : maxPrice - minPrice;

    final n = history.length;
    final w = size.width;
    final h = size.height;

    // Pad top and bottom
    const bottomAxisHeight = 30.0;
    final chartH = h - bottomAxisHeight;
    const verticalPadding = 0.15;
    final usableHeight = chartH * (1 - verticalPadding * 2);

    double getX(int i) => (i / (n - 1)) * w;
    double getY(double p) {
      final normalized = (p - minPrice) / range;
      return chartH - (chartH * verticalPadding) - (normalized * usableHeight);
    }

    if (onlyRightAxis) {
      _drawRightAxis(
        canvas,
        size,
        minPrice,
        maxPrice,
        range,
        chartH * verticalPadding,
        usableHeight,
        chartH,
      );
      return;
    }

    // ── 1. Position Background Shading ──
    final greenBg = Paint()..color = _kGreen.withOpacity(0.08);
    final redBg = Paint()..color = _kRed.withOpacity(0.05);

    for (int i = 0; i < n - 1; i++) {
      final p1 = history[i];
      final startX = getX(i);
      final endX = getX(i + 1);
      final rect = Rect.fromLTRB(startX, 0, endX, chartH);

      if (p1.position > 0) {
        canvas.drawRect(rect, greenBg);
      } else {
        canvas.drawRect(rect, redBg);
      }
    }

    // ── 2. Grid Lines & Bottom Axis ──
    final gridPaint = Paint()
      ..color = _kWhite.withOpacity(0.04)
      ..strokeWidth = 1;

    // Horizontal grids
    for (int i = 0; i <= 4; i++) {
      final y = chartH * verticalPadding + (usableHeight * (i / 4));
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Vertical grids & Bottom Axis Labels
    final step = (100.0 / w * n).ceil().clamp(1, n);
    for (int i = 0; i < n; i += step) {
      // Prevent label overlapping the very end
      if (i > 0 && i > n - step * 0.7) continue;

      final x = getX(i);
      canvas.drawLine(Offset(x, 0), Offset(x, chartH), gridPaint);

      final date = history[i].date;
      final dateStr = '${date.day} ${_monthName(date.month)}';

      final textPainter = TextPainter(
        text: TextSpan(
          text: dateStr,
          style: GoogleFonts.inter(
            color: const Color(0xFF9B9EA3),
            fontSize: 10,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, chartH + 8));
    }

    // ── 3. Price Line Series ──
    final path = Path();
    path.moveTo(getX(0), getY(history[0].price));
    for (int i = 1; i < n; i++) {
      path.lineTo(getX(i), getY(history[i].price));
    }

    final paintLine = Paint()
      ..color =
          const Color(0xFF888888) // matching LightweightCharts grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paintLine);

    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF888888).withOpacity(0.2)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // ── 4. BUY / SELL Markers ──
    final buyPaint = Paint()
      ..color = const Color(0xFF26a69a); // TradingView Green
    final sellPaint = Paint()
      ..color = const Color(0xFFef5350); // TradingView Red

    for (int i = 0; i < n; i++) {
      final point = history[i];
      if (point.isBuy || point.isSell) {
        final x = getX(i);
        final y = getY(point.price);
        final isBuy = point.isBuy;

        final arrowPath = Path();
        if (isBuy) {
          final arrowY = y + 12;
          arrowPath.moveTo(x, arrowY - 5);
          arrowPath.lineTo(x - 5, arrowY + 5);
          arrowPath.lineTo(x + 5, arrowY + 5);
          arrowPath.close();
          canvas.drawPath(arrowPath, buyPaint);
          _drawMarkerText(
            canvas,
            'BUY',
            Offset(x, arrowY + 12),
            const Color(0xFF26a69a),
          );
        } else {
          final arrowY = y - 12;
          arrowPath.moveTo(x, arrowY + 5);
          arrowPath.lineTo(x - 5, arrowY - 5);
          arrowPath.lineTo(x + 5, arrowY - 5);
          arrowPath.close();
          canvas.drawPath(arrowPath, sellPaint);
          _drawMarkerText(
            canvas,
            'SELL',
            Offset(x, arrowY - 12),
            const Color(0xFFef5350),
          );
        }
      }
    }

    // ── 5. Crosshair ──
    if (crosshairPosition != null) {
      int closestIndex = 0;
      double minDiff = double.infinity;
      for (int i = 0; i < n; i++) {
        final diff = (getX(i) - crosshairPosition!.dx).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIndex = i;
        }
      }

      final cx = getX(closestIndex);
      final cy = getY(history[closestIndex].price);

      final crossPaint = Paint()
        ..color = const Color(0x4D00D2FF)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // Cross lines
      canvas.drawLine(Offset(cx, 0), Offset(cx, h), crossPaint);
      canvas.drawLine(Offset(0, cy), Offset(w, cy), crossPaint);
      canvas.drawCircle(
        Offset(cx, cy),
        4,
        Paint()..color = const Color(0xFF00D2FF),
      );

      // Tooltips
      final date = history[closestIndex].date;
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      _drawTooltipBox(canvas, dateStr, Offset(cx, h - 10));

      final thbPrice = _normalizeToThb(history[closestIndex].price);
      final priceStr = CurrencyProvider().formatValue(
        thbPrice,
        includeSymbol: true,
      );
      _drawTooltipBox(canvas, priceStr, Offset(cx + 45, cy));
    }
  }

  void _drawRightAxis(
    Canvas canvas,
    Size size,
    double minPrice,
    double maxPrice,
    double range,
    double topPadding,
    double usableHeight,
    double chartH,
  ) {
    final textStyle = GoogleFonts.inter(
      color: const Color(0xFF9B9EA3),
      fontSize: 10,
    );

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (usableHeight * (i / 4));
      final price = maxPrice - (range * (i / 4));

      final thbPrice = _normalizeToThb(price);
      final textPainter = TextPainter(
        text: TextSpan(
          text: CurrencyProvider().formatValue(thbPrice, includeSymbol: true),
          style: textStyle,
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y - textPainter.height / 2));
    }
  }

  void _drawMarkerText(Canvas canvas, String text, Offset center, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawTooltipBox(Canvas canvas, String text, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.inter(
          color: _kWhite,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();

    final rect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 12,
      height: textPainter.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = _kCard,
    );
    textPainter.paint(canvas, Offset(rect.left + 6, rect.top + 4));
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return history != oldDelegate.history ||
        color != oldDelegate.color ||
        crosshairPosition != oldDelegate.crosshairPosition ||
        currency != oldDelegate.currency;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _AiPredictionSection
// ═══════════════════════════════════════════════════════════════════════════════
class _AiPredictionSection extends StatelessWidget {
  final List<Map<String, dynamic>> predictions;
  final bool isLoading;
  const _AiPredictionSection({required this.predictions, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Text(
            'AI Prediction History',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _kWhite),
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: _kRed)),
          )
        else if (predictions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Center(
              child: Text(
                'No prediction history found for this asset',
                style: GoogleFonts.inter(fontSize: 13, color: _kWhite50),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else ...[
          _LatestPredictionCard(prediction: predictions.first),
          if (predictions.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                children: [
                  for (int i = 1; i < predictions.length; i++)
                    _OlderPredictionRow(
                      prediction: predictions[i],
                      isLast: i == predictions.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _LatestPredictionCard  — identical layout to home _PredictionItem + LATEST badge
// ═══════════════════════════════════════════════════════════════════════════════
class _LatestPredictionCard extends StatelessWidget {
  final Map<String, dynamic> prediction;
  const _LatestPredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final symbol = (prediction['market'] ?? prediction['symbol'] ?? '') as String;
    final trend = (prediction['trend_regime'] ?? prediction['overallTrend'] ?? 'neutral') as String;
    final signal = (prediction['signal_action'] ?? 'WAIT') as String;
    final timeRaw = (prediction['date'] ?? prediction['predictedAt']) as String?;
    final price = ((prediction['price'] ?? prediction['currentPrice']) as num?)?.toDouble() ?? 0.0;

    String time = '--/--/---- --:--';
    if (timeRaw != null) {
      try {
        final dt = DateTime.parse(timeRaw).toLocal();
        final d = dt.day.toString().padLeft(2, '0');
        final mo = dt.month.toString().padLeft(2, '0');
        final yr = dt.year.toString();
        final h = dt.hour.toString().padLeft(2, '0');
        final mi = dt.minute.toString().padLeft(2, '0');
        time = '$d/$mo/$yr $h:$mi';
      } catch (_) {}
    }

    final isUptrend = trend.toLowerCase().contains('uptrend') || trend.toLowerCase().contains('bullish');
    final isDowntrend = trend.toLowerCase().contains('downtrend') || trend.toLowerCase().contains('bearish');
    final trendLabel = isUptrend ? 'Uptrend' : (isDowntrend ? 'Downtrend' : 'Neutral');
    final sigUp = signal.toUpperCase();
    final isHold = sigUp == 'HOLD';
    final isBuy = sigUp == 'BUY';
    final isSell = sigUp == 'SELL';
    final signalColor = isBuy
        ? _kGreen
        : isSell
            ? _kRed
            : isHold
                ? const Color(0xFFFFB547) // amber for HOLD
                : _kWhite;

    // ── Exact same layout as home _PredictionItem ──
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF282828), width: 1),
      ),
      child: Row(
        children: [
          // Coin icon 33px
          ClipOval(
            child: AssetHelper.isSvg(AssetHelper.getAssetImagePath(symbol))
                ? SvgPicture.asset(
                    AssetHelper.getAssetImagePath(symbol),
                    width: 33, height: 33, fit: BoxFit.cover,
                    placeholderBuilder: (_) => Container(
                      width: 33, height: 33, color: const Color(0xFF282828),
                      child: const Icon(Icons.show_chart, color: Colors.white24, size: 16),
                    ),
                  )
                : Image.asset(
                    AssetHelper.getAssetImagePath(symbol),
                    width: 33, height: 33, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 33, height: 33, color: const Color(0xFF282828),
                      child: const Icon(Icons.show_chart, color: Colors.white24, size: 16),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          // Info (Middle Column)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: LATEST tag + Signal badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: signalColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: signalColor.withOpacity(0.35), width: 0.5),
                      ),
                      child: Text(
                        'LATEST',
                        style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: signalColor, letterSpacing: 0.6),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Signal badge (Moved up next to LATEST)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: signalColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: signalColor.withOpacity(0.3), width: 0.5),
                      ),
                      child: Text(
                        signal,
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: signalColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Line 2: Trend Label only (Size matched to price 14px)
                Text(
                  trendLabel,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xEEFFFFFF)),
                ),
              ],
            ),
          ),
          // Right Column: Time (Above) and Price (Below)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Time (Increased font size)
              Text(
                time,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0x80FFFFFF)),
              ),
              const SizedBox(height: 4),
              // Price
              ListenableBuilder(
                listenable: CurrencyProvider(),
                builder: (context, _) => Text(
                  CurrencyProvider().formatValue(price),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: _kWhite),
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
// _OlderPredictionRow  — compact history card with left accent bar
// ═══════════════════════════════════════════════════════════════════════════════
class _OlderPredictionRow extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final bool isLast;
  const _OlderPredictionRow({required this.prediction, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final trend = (prediction['trend_regime'] ?? prediction['overallTrend'] ?? 'neutral') as String;
    final signal = (prediction['signal_action'] ?? 'WAIT') as String;
    final timeRaw = (prediction['date'] ?? prediction['predictedAt']) as String?;
    final price = ((prediction['price'] ?? prediction['currentPrice']) as num?)?.toDouble() ?? 0.0;

    String time = '--';
    if (timeRaw != null) {
      try {
        final dt = DateTime.parse(timeRaw).toLocal();
        final d = dt.day.toString().padLeft(2, '0');
        final mo = dt.month.toString().padLeft(2, '0');
        final h = dt.hour.toString().padLeft(2, '0');
        final mi = dt.minute.toString().padLeft(2, '0');
        time = '$d/$mo $h:$mi';
      } catch (_) {}
    }

    final isUptrend = trend.toLowerCase().contains('uptrend') || trend.toLowerCase().contains('bullish');
    final isDowntrend = trend.toLowerCase().contains('downtrend') || trend.toLowerCase().contains('bearish');
    final trendLabel = isUptrend ? 'Uptrend' : (isDowntrend ? 'Downtrend' : 'Neutral');
    final sigUp = signal.toUpperCase();
    final isHold = sigUp == 'HOLD';
    final isBuy = sigUp == 'BUY';
    final isSell = sigUp == 'SELL';
    final signalColor = isBuy
        ? _kGreen
        : isSell
            ? _kRed
            : isHold
                ? const Color(0xFFFFB547)
                : const Color(0x80FFFFFF);

    // Use clipBehavior + inner Row for left accent (avoids borderRadius+non-uniform-border crash)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF242424), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar (clipped by parent to round corners)
            Container(
              width: 3,
              color: signalColor.withOpacity(0.65),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Signal badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: signalColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: signalColor.withOpacity(0.2), width: 0.5),
                      ),
                      child: Text(
                        signal,
                        style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: signalColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(trendLabel, style: GoogleFonts.inter(fontSize: 11, color: const Color(0x80FFFFFF))),
                    const SizedBox(width: 8),
                    Text(time, style: GoogleFonts.inter(fontSize: 10, color: _kWhite.withOpacity(0.22))),
                    const Spacer(),
                    ListenableBuilder(
                      listenable: CurrencyProvider(),
                      builder: (context, _) => Text(
                        CurrencyProvider().formatValue(price),
                        style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0x80FFFFFF),
                        ),
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
}
