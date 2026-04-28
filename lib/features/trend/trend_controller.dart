import 'package:dio/dio.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class TrendDataPoint {
  final DateTime date;
  final double price;
  final String signalAction; // BUY / SELL / HOLD / WAIT
  final double mlUpProb;
  final double mlDownProb;
  final String trendRegime;
  final double position; // 1.0 (In Position) or 0.0 (Out of Position)

  const TrendDataPoint({
    required this.date,
    required this.price,
    required this.signalAction,
    required this.mlUpProb,
    required this.mlDownProb,
    required this.trendRegime,
    required this.position,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
      signalAction: (json['signal_action'] as String? ?? 'HOLD').toUpperCase(),
      mlUpProb: (json['ml_up_prob'] as num? ?? 50).toDouble(),
      mlDownProb: (json['ml_down_prob'] as num? ?? 50).toDouble(),
      trendRegime: json['trend_regime'] as String? ?? '',
      position: (json['position'] as num? ?? 0.0).toDouble(),
    );
  }

  bool get isBuy => signalAction == 'BUY';
  bool get isSell => signalAction == 'SELL';
  bool get isUptrend => trendRegime.contains('1');
}

// ─── Stats Model ─────────────────────────────────────────────────────────────

class TrendStats {
  final double baseReturnPct;
  final double bnhReturnPct;
  final double winRatePct;
  final int totalTrades;
  final double maxDrawdownPct;

  const TrendStats({
    required this.baseReturnPct,
    required this.bnhReturnPct,
    required this.winRatePct,
    required this.totalTrades,
    required this.maxDrawdownPct,
  });

  factory TrendStats.fromJson(Map<String, dynamic> json) {
    return TrendStats(
      baseReturnPct: (json['base_return_pct'] as num? ?? 0).toDouble(),
      bnhReturnPct: (json['bnh_return_pct'] as num? ?? 0).toDouble(),
      winRatePct: (json['win_rate_pct'] as num? ?? 0).toDouble(),
      totalTrades: (json['total_trades'] as num? ?? 0).toInt(),
      maxDrawdownPct: (json['max_drawdown_pct'] as num? ?? 0).toDouble(),
    );
  }
}

// ─── Trend Controller ─────────────────────────────────────────────────────────

class TrendController {
  static final TrendController _instance = TrendController._internal();
  factory TrendController() => _instance;
  TrendController._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // Maps a frontend asset symbol to the AI backend market key
  static String? symbolToMarket(String symbol) {
    final s = symbol.toUpperCase();
    if (s == 'BTC' || s.contains('BTC')) return 'BTC';
    if (s == 'GOLD' || s.contains('XAU') || s.contains('GOLD')) return 'Gold';
    if (s.contains('SET') || s == 'THAI') return 'Thai';
    if (s == 'UK' || s.contains('UK') || s.contains('FTSE')) return 'UK';
    if (s == 'US' || s.contains('SP') || s.contains('US') || s.contains('S&P')) return 'US';
    return null;
  }

  /// Fetches history and stats for a given asset symbol.
  /// Returns null if the symbol has no AI market mapping or on error.
  Future<({List<TrendDataPoint> history, TrendStats? stats})?> fetchTrendData(
      String symbol) async {
    final market = symbolToMarket(symbol);
    if (market == null) return null;

    try {
      final res = await _dio.get('/api/data', queryParameters: {'market': market});
      if (res.statusCode == 200 && res.data != null) {
        final rawHistory = (res.data['history'] as List?) ?? [];
        final history = rawHistory
            .map((row) => TrendDataPoint.fromJson(row as Map<String, dynamic>))
            .toList();

        TrendStats? stats;
        if (res.data['stats'] != null) {
          stats = TrendStats.fromJson(res.data['stats'] as Map<String, dynamic>);
        }

        return (history: history, stats: stats);
      }
    } catch (e) {
      print('[TrendController] Error fetching data for $symbol: $e');
    }
    return null;
  }
}
