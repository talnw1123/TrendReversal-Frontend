import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg      = Color(0xFF121212);
const Color _kCard    = Color(0xFF282828);
const Color _kRed     = Color(0xFFE4472B);
const Color _kGreen   = Color(0xFF47D5A6);
const Color _kWhite   = Color(0xFFFFFFFF);
const Color _kWhite50 = Color(0x80FFFFFF);
const Color _kWhite20 = Color(0x33FFFFFF);

// ─── Time Frames ──────────────────────────────────────────────────────────────
const List<String> _kTimeFrames = ['1m', '30m', '1h', '5h', 'D', 'W', 'M', 'Y', 'All'];
const int _kDefaultTimeFrame = 2; // '1h'

// ─── Stats Tabs ───────────────────────────────────────────────────────────────
const List<String> _kStatsTabs = ['Key stats', 'Order History', 'Deals', 'Information'];

// ─── Key Stats ────────────────────────────────────────────────────────────────
class _KeyStat {
  final String label;
  final String value;
  final Color? valueColor;
  const _KeyStat({required this.label, required this.value, this.valueColor});
}

const List<_KeyStat> _kLeftStats = [
  _KeyStat(label: 'Open',       value: '4,340.23'),
  _KeyStat(label: 'Close',      value: '4,340.23'),
  _KeyStat(label: 'Market vol', value: '108.5M'),
];

const List<_KeyStat> _kRightStats = [
  _KeyStat(label: 'Current', value: '4,340.23'),
  _KeyStat(label: 'High',    value: '4,340.23', valueColor: _kGreen),
  _KeyStat(label: 'Low',     value: '4,340.23', valueColor: _kRed),
];

// ─── Trend Predictions ────────────────────────────────────────────────────────
class _TrendPrediction {
  final String period;
  final String value;
  final String time;
  const _TrendPrediction({
    required this.period,
    required this.value,
    required this.time,
  });
}

const List<_TrendPrediction> _kUptrendData = [
  _TrendPrediction(period: 'After hours:', value: '4,330.39 +10.00 +0.50%', time: '20:59 01/12'),
  _TrendPrediction(period: 'After hours:', value: '4,330.39 +10.00 +0.50%', time: '19:59 01/12'),
  _TrendPrediction(period: 'After days:',  value: '4,335.39 +2.00 +0.50%',  time: '19:59 31/10'),
  _TrendPrediction(period: 'After days:',  value: '4,340.39 +2.00 +1.20%',  time: '19:00 31/10'),
  _TrendPrediction(period: 'After month:', value: '4,340.39 +2.00 +1.20%',  time: '19:00 30/09'),
];

const List<_TrendPrediction> _kDowntrendData = [
  _TrendPrediction(period: 'After hours:', value: '4,330.39 -10.00 -0.50%', time: '20:59 01/12'),
  _TrendPrediction(period: 'After hours:', value: '4,330.39 -10.00 -0.50%', time: '19:59 01/12'),
  _TrendPrediction(period: 'After days:',  value: '4,335.39 -2.00 -0.50%',  time: '19:59 31/10'),
  _TrendPrediction(period: 'After days:',  value: '4,340.39 -2.00 -1.20%',  time: '19:00 31/10'),
  _TrendPrediction(period: 'After month:', value: '4,340.39 -2.00 -1.20%',  time: '19:00 30/09'),
];

// ─── Chart toolbar icons ──────────────────────────────────────────────────────
const List<(String, String)> _kToolIcons = [
  ('assets/icons/trend_tool_candles.svg',   'Candle chart'),
  ('assets/icons/trend_tool_camera.svg',    'Camera'),
  ('assets/icons/trend_tool_zoom_in.svg',   'Zoom in'),
  ('assets/icons/trend_tool_zoom_out.svg',  'Zoom out'),
  ('assets/icons/trend_tool_text.svg',      'Text annotation'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// TrendScreen
// ═══════════════════════════════════════════════════════════════════════════════
class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  int  _selectedTimeFrame = _kDefaultTimeFrame;
  int  _selectedStatsTab  = 0;
  bool _isUptrend         = true;

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
              const SizedBox(height: 14),

              // ── App Bar ──────────────────────────────────────────────────
              _TrendAppBar(),
              const SizedBox(height: 20),

              // ── Price ────────────────────────────────────────────────────
              _PriceHeader(),
              const SizedBox(height: 6),

              // ── After hours row ──────────────────────────────────────────
              _AfterHoursHeader(isUptrend: _isUptrend),
              const SizedBox(height: 10),

              // ── Separator ────────────────────────────────────────────────
              Container(height: 2, color: _kWhite20),

              // ── Time frame selector ──────────────────────────────────────
              _TimeFrameSelector(
                selectedIndex: _selectedTimeFrame,
                onSelected: (i) => setState(() => _selectedTimeFrame = i),
              ),

              // ── Candlestick chart ────────────────────────────────────────
              AspectRatio(
                aspectRatio: 440 / 377,
                child: SvgPicture.asset(
                  'assets/icons/trend_candles_chart.svg',
                  fit: BoxFit.fill,
                ),
              ),

              // ── Volume bars ──────────────────────────────────────────────
              SizedBox(
                height: 57,
                child: SvgPicture.asset(
                  'assets/icons/trend_volume_bars.svg',
                  fit: BoxFit.fill,
                ),
              ),

              // ── Chart toolbar ────────────────────────────────────────────
              _ChartToolbar(),

              // ── Stats tab bar ─────────────────────────────────────────────
              _StatsTabBar(
                selectedIndex: _selectedStatsTab,
                onSelected: (i) => setState(() => _selectedStatsTab = i),
              ),

              // ── Stats content ─────────────────────────────────────────────
              if (_selectedStatsTab == 0) ...[
                const SizedBox(height: 12),
                _StatsGrid(),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Center(
                    child: Text(
                      _kStatsTabs[_selectedStatsTab],
                      style: GoogleFonts.inter(fontSize: 14, color: _kWhite50),
                    ),
                  ),
                ),

              // ── Predicted trend ──────────────────────────────────────────
              _PredictedTrendSection(
                isUptrend: _isUptrend,
                onToggle: (v) => setState(() => _isUptrend = v),
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
  const _TrendAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Back button
          Tooltip(
            message: 'Back',
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: _kWhite,
                  size: 22,
                ),
              ),
            ),
          ),

          // Title – centered via Expanded
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Solana ',
                      style: TextStyle(
                        fontFamily: 'Franklin Gothic Demi',
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: _kWhite,
                      ),
                    ),
                    TextSpan(
                      text: '(SOL)',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: _kWhite50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Symmetry spacer
          const SizedBox(width: 34),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PriceHeader
// ═══════════════════════════════════════════════════════════════════════════════
class _PriceHeader extends StatelessWidget {
  const _PriceHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Price
          Text(
            '4,340.39',
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w400,
              color: _kWhite,
            ),
          ),
          const SizedBox(width: 8),
          // Change indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/trend_price_down_arrow.svg',
                width: 12,
                height: 6,
                colorFilter: const ColorFilter.mode(_kRed, BlendMode.srcIn),
              ),
              const SizedBox(width: 3),
              Text(
                '-0.54%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _kWhite,
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
// _AfterHoursHeader
// ═══════════════════════════════════════════════════════════════════════════════
class _AfterHoursHeader extends StatelessWidget {
  final bool isUptrend;
  const _AfterHoursHeader({required this.isUptrend});

  @override
  Widget build(BuildContext context) {
    final changeText  = isUptrend ? '4,330.39 +10.00 +0.50%' : '4,330.39 -10.00 -0.50%';
    final changeColor = isUptrend ? _kGreen : _kRed;

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          Text(
            'After hours:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kWhite50,
            ),
          ),
          Text(
            changeText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: changeColor,
            ),
          ),
          Container(width: 1, height: 10, color: _kWhite50),
          Text(
            '20:59 01/11',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kWhite,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Time frame:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kWhite50,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_kTimeFrames.length, (i) {
                final isSelected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelected(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _kTimeFrames[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? _kWhite : _kWhite50,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _ChartToolbar
// ═══════════════════════════════════════════════════════════════════════════════
class _ChartToolbar extends StatelessWidget {
  const _ChartToolbar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          // ── 5 plain tool icons ───────────────────────────────────────────
          ...List.generate(_kToolIcons.length, (i) {
            final (path, label) = _kToolIcons[i];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: label,
                child: SvgPicture.asset(
                  path,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(_kWhite, BlendMode.srcIn),
                ),
              ),
            );
          }),

          // ── Active chart icon (red container) ────────────────────────────
          Tooltip(
            message: 'Trend chart',
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _kRed,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/trend_tool_chart_active.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(_kWhite, BlendMode.srcIn),
              ),
            ),
          ),

          const Spacer(),

          // ── AI + close button ─────────────────────────────────────────────
          SvgPicture.asset(
            'assets/icons/trend_ai_close_btn.svg',
            width: 52,
            height: 24,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _StatsTabBar
// ═══════════════════════════════════════════════════════════════════════════════
class _StatsTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const _StatsTabBar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_kStatsTabs.length, (i) {
          final isSelected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < _kStatsTabs.length - 1 ? 18.0 : 0),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: isSelected
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                    : EdgeInsets.zero,
                decoration: isSelected
                    ? BoxDecoration(
                        color: _kRed,
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: Text(
                  _kStatsTabs[i],
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? _kWhite : _kWhite50,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _StatsGrid
// ═══════════════════════════════════════════════════════════════════════════════
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // ── Left column ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_kLeftStats.length, (i) => Padding(
                padding: EdgeInsets.only(bottom: i < _kLeftStats.length - 1 ? 18 : 0),
                child: _StatRow(stat: _kLeftStats[i]),
              )),
            ),
          ),

          const SizedBox(width: 12),

          // ── Right column ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_kRightStats.length, (i) => Padding(
                padding: EdgeInsets.only(bottom: i < _kRightStats.length - 1 ? 18 : 0),
                child: _StatRow(stat: _kRightStats[i]),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final _KeyStat stat;
  const _StatRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          stat.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _kWhite50,
          ),
        ),
        Text(
          stat.value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: stat.valueColor ?? _kWhite,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PredictedTrendSection
// ═══════════════════════════════════════════════════════════════════════════════
class _PredictedTrendSection extends StatelessWidget {
  final bool isUptrend;
  final ValueChanged<bool> onToggle;
  const _PredictedTrendSection({required this.isUptrend, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final predictions = isUptrend ? _kUptrendData : _kDowntrendData;
    final valueColor  = isUptrend ? _kGreen : _kRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // ── Heading ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Predicted trend',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kWhite,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Toggle ────────────────────────────────────────────────────────
        _TrendToggle(isUptrend: isUptrend, onToggle: onToggle),

        // ── Prediction list ───────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Column(
            key: ValueKey(isUptrend),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < predictions.length; i++) ...[
                Container(height: 1, color: _kWhite20),
                _TrendRow(data: predictions[i], valueColor: valueColor),
              ],
              Container(height: 1, color: _kWhite20),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── _TrendToggle ─────────────────────────────────────────────────────────────
class _TrendToggle extends StatelessWidget {
  final bool isUptrend;
  final ValueChanged<bool> onToggle;
  const _TrendToggle({required this.isUptrend, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: _kCard,
      child: Row(
        children: [
          // Uptrend tab
          Expanded(
            child: Semantics(
              label: 'Uptrend tab',
              selected: isUptrend,
              button: true,
              child: GestureDetector(
                onTap: () => onToggle(true),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Uptrend',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isUptrend ? _kGreen : _kWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: isUptrend ? 58.0 : 0.0,
                      decoration: BoxDecoration(
                        color: _kGreen,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Downtrend tab
          Expanded(
            child: Semantics(
              label: 'Downtrend tab',
              selected: !isUptrend,
              button: true,
              child: GestureDetector(
                onTap: () => onToggle(false),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Downtrend',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: !isUptrend ? _kRed : _kWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: !isUptrend ? 80.0 : 0.0,
                      decoration: BoxDecoration(
                        color: _kRed,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _TrendRow ────────────────────────────────────────────────────────────────
class _TrendRow extends StatelessWidget {
  final _TrendPrediction data;
  final Color valueColor;
  const _TrendRow({required this.data, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      child: Row(
        children: [
          // Period label
          SizedBox(
            width: 92,
            child: Text(
              data.period,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _kWhite50,
              ),
            ),
          ),
          // Value
          Expanded(
            child: Text(
              data.value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Time
          Text(
            data.time,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kWhite,
            ),
          ),
        ],
      ),
    );
  }
}
