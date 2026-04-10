import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  static final CurrencyProvider _instance = CurrencyProvider._internal();
  factory CurrencyProvider() => _instance;
  CurrencyProvider._internal();

  String _currentCurrency = 'THB';
  double _usdRate = 36.5; // Default fallback

  String get currentCurrency => _currentCurrency;
  double get usdRate => _usdRate;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString('currency') ?? 'THB';
    notifyListeners();
  }

  void setUsdRate(double rate) {
    _usdRate = rate;
    notifyListeners();
  }

  Future<void> toggleCurrency() async {
    _currentCurrency = _currentCurrency == 'THB' ? 'USD' : 'THB';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', _currentCurrency);
    notifyListeners();
  }

  double convert(double value) {
    if (_currentCurrency == 'USD') {
      return value / _usdRate;
    }
    return value;
  }

  String formatValue(double value) {
    final converted = convert(value);
    final symbol = _currentCurrency == 'THB' ? 'THB' : '\$';
    if (_currentCurrency == 'THB') {
      return '${converted.toStringAsFixed(0)} $symbol';
    }
    return '$symbol${converted.toStringAsFixed(2)}';
  }
}
