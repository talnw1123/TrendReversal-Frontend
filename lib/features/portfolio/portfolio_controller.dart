import 'package:dio/dio.dart';
import '../../core/auth_service.dart';

// ─── Portfolio Controller (Singleton) ──────────────────────────────────────────
// Handles all API calls for the portfolio feature with auto-auth and versioning.

class PortfolioController {
  static final PortfolioController _instance = PortfolioController._internal();
  factory PortfolioController() => _instance;
  PortfolioController._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Map<String, dynamic> get _authHeaders {
    final token = AuthService().token;
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  // ── Get Portfolio Data (Items + Summary) ─────────────────────────────────────
  Future<Map<String, dynamic>?> getPortfolioData() async {
    try {
      final res = await _dio.get(
        '/v1/portfolio',
        options: Options(headers: _authHeaders),
      );
      // Backend returns { summary: {}, items: [] }
      return res.data;
    } catch (e) {
      print('[PortfolioController] Fetch Error: $e');
      return null;
    }
  }

  // Legacy support or quick helper
  Future<List<dynamic>> getItems() async {
    final data = await getPortfolioData();
    return data?['items'] ?? [];
  }

  // ── Add Portfolio Item ───────────────────────────────────────────────────────
  Future<bool> addItem({
    required String assetId,
    required double quantity,
    required double buyPrice,
    required String buyDate,
    String? currency,
  }) async {
    try {
      await _dio.post(
        '/v1/portfolio',
        data: {
          'assetId': assetId,
          'quantity': quantity,
          'buyPrice': buyPrice,
          'buyDate': buyDate,
          if (currency != null) 'currency': currency,
        },
        options: Options(headers: _authHeaders),
      );
      return true;
    } catch (e) {
      print('[PortfolioController] Add Error: $e');
      return false;
    }
  }

  // ── Delete Portfolio Item ────────────────────────────────────────────────────
  Future<bool> deleteItem(String id) async {
    try {
      await _dio.delete(
        '/v1/portfolio/$id',
        options: Options(headers: _authHeaders),
      );
      return true;
    } catch (e) {
      print('[PortfolioController] Delete Error: $e');
      return false;
    }
  }

  // ── Get Exchange Rate ────────────────────────────────────────────────────────
  Future<double?> getUsdRate() async {
    try {
      final res = await _dio.get('/v1/assets/exchange-rate/usd');
      return (res.data['rate'] as num?)?.toDouble();
    } catch (e) {
      return null;
    }
  }
}
