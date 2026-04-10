import 'package:dio/dio.dart';

class PortfolioController {
  final _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Future<Map<String, dynamic>> getPortfolioData() async {
    try {
      final res = await _dio.get('/portfolio');
      return res.data;
    } catch (e) {
      print('Error fetching portfolio: $e');
      rethrow;
    }
  }

  Future<void> addPortfolioItem({
    required String assetId,
    required String assetLabel,
    required double buyPrice,
    required double quantity,
    required String purchaseDate,
  }) async {
    try {
      await _dio.post('/portfolio', data: {
        'assetId': assetId,
        'assetLabel': assetLabel,
        'buyPrice': buyPrice,
        'quantity': quantity,
        'purchaseDate': purchaseDate,
      });
    } catch (e) {
      print('Error adding asset: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _dio.delete('/portfolio/$id');
    } catch (e) {
      print('Error deleting asset: $e');
      rethrow;
    }
  }

  Future<double> getUsdRate() async {
    try {
      final res = await _dio.get('/assets/exchange-rate/usd');
      return double.tryParse(res.data['rate']?.toString() ?? '36.5') ?? 36.5;
    } catch (e) {
      return 36.5;
    }
  }
}
