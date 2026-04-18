import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Currency Provider (Singleton + ChangeNotifier) ───────────────────────────
// Global state manager for THB/USD currency toggle.
// Usage: CurrencyProvider().currentCurrency  → 'THB' or 'USD'
//        ListenableBuilder(listenable: CurrencyProvider(), builder: ...)

class CurrencyProvider extends ChangeNotifier {
  // Singleton
  static final CurrencyProvider _instance = CurrencyProvider._internal();
  factory CurrencyProvider() => _instance;
  CurrencyProvider._internal();

  // State
  String _currency = 'THB';
  double _usdRate = 33.0; // fallback rate (1 USD = 33 THB)

  // Getters
  String get currentCurrency => _currency;
  double get usdRate => _usdRate;
  bool get isUsd => _currency == 'USD';

  // ── Persistence ─────────────────────────────────────────────────────────────
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString('currency') ?? 'THB';
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    if (_currency == currency) return;
    _currency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  void setUsdRate(double rate) {
    if (rate > 0 && _usdRate != rate) {
      _usdRate = rate;
      notifyListeners();
    }
  }

  // ── Toggle ──────────────────────────────────────────────────────────────────
  Future<void> toggle() async {
    await setCurrency(_currency == 'THB' ? 'USD' : 'THB');
  }

  // ── Conversion ──────────────────────────────────────────────────────────────
  /// Convert a THB value to the current display currency.
  double convert(double thbValue) {
    if (isUsd) return thbValue / _usdRate;
    return thbValue;
  }

  // ── Formatting ──────────────────────────────────────────────────────────────
  String formatValue(double thbValue, {bool includeSymbol = true}) {
    final displayValue = convert(thbValue);
    if (!includeSymbol) return _fmt(displayValue);
    final prefix = isUsd ? '\$' : '฿';
    return '$prefix${_fmt(displayValue)}';
  }

  String _fmt(double v) {
    final absV = v.abs();
    String formatted;
    if (absV >= 1000000) {
      formatted = '${(absV / 1000000).toStringAsFixed(2)}M';
    } else if (absV >= 1000) {
      final parts = absV.toStringAsFixed(2).split('.');
      final intPart = parts[0]
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
      formatted = '$intPart.${parts[1]}';
    } else {
      formatted = absV.toStringAsFixed(2);
    }
    return v < 0 ? '-$formatted' : formatted;
  }
}
