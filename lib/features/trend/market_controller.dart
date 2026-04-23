import 'package:dio/dio.dart';

// ─── Market Controller (Singleton) ──────────────────────────────────────────
// Handles fetching real-time asset prices from the backend.

class MarketController {
  static final MarketController _instance = MarketController._internal();
  factory MarketController() => _instance;
  MarketController._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:4000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetches a list of real assets from the backend endpoints.
  Future<List<Map<String, dynamic>>> getMarketAssets() async {
    try {
      final List<String> endpoints = [
        '/v1/assets/price/us',   // S&P 500
        '/v1/assets/price/thai', // SET 50
        '/v1/assets/price/gold', // Gold
        '/v1/assets/price/btc',  // Bitcoin
        '/v1/assets/price/uk',   // FTSE 100
      ];

      final responses = await Future.wait(
        endpoints.map((e) => _dio.get(e)),
      );

      return responses.map((res) => res.data as Map<String, dynamic>).toList();
    } catch (e) {
      print('[MarketController] Error fetching assets: $e');
      return [];
    }
  }
}
