import 'package:dio/dio.dart';
import '../../core/auth_service.dart';

class AiController {
  static final AiController _instance = AiController._internal();
  factory AiController() => _instance;
  AiController._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:4000/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60), 
  ));

  Map<String, dynamic> get _authHeaders {
    final token = AuthService().token;
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  // ── Session Management ───────────────────────────────────────────────────────
  
  Future<List<dynamic>> getChatSessions() async {
    try {
      final res = await _dio.get('/v1/chat/sessions', options: Options(headers: _authHeaders));
      return res.data as List<dynamic>;
    } catch (e) {
      print('[AiController] getSessions Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createSession(String title) async {
    try {
      final res = await _dio.post('/v1/chat/sessions', 
        data: {'title': title},
        options: Options(headers: _authHeaders)
      );
      return res.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    try {
      final res = await _dio.get('/v1/chat/sessions/$sessionId', options: Options(headers: _authHeaders));
      return res.data;
    } catch (e) {
      return null;
    }
  }

  // ── Messaging ────────────────────────────────────────────────────────────────
  
  Future<Map<String, dynamic>?> sendMessage(String sessionId, String content) async {
    try {
      final res = await _dio.post('/v1/chat/sessions/$sessionId/messages',
        data: {'content': content},
        options: Options(headers: _authHeaders)
      );
      return res.data; // { userMessage: {}, aiMessage: {} }
    } catch (e) {
      print('[AiController] sendMessage Error: $e');
      return null;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete('/v1/chat/sessions/$sessionId', options: Options(headers: _authHeaders));
    } catch (e) {
      print('[AiController] deleteSession Error: $e');
    }
  }

  Future<bool> renameSession(String sessionId, String newTitle) async {
    try {
      await _dio.post('/v1/chat/sessions/$sessionId/rename',
        data: {'title': newTitle},
        options: Options(headers: _authHeaders)
      );
      return true;
    } catch (e) {
      print('[AiController] renameSession Error: $e');
      return false;
    }
  }

  // ── Predictions ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getPrediction(String symbol, {String timeframe = '1h'}) async {
    try {
      final res = await _dio.post('/v1/predictions',
        data: {
          'symbol': symbol,
          'timeframe': timeframe,
        },
        options: Options(headers: _authHeaders)
      );
      return res.data;
    } catch (e) {
      print('[AiController] getPrediction Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getLatestPredictions({int limit = 5}) async {
    try {
      final res = await _dio.get('/v1/predictions/latest',
        queryParameters: {'limit': limit},
        options: Options(headers: _authHeaders)
      );
      if (res.data != null && res.data['predictions'] != null) {
        return List<Map<String, dynamic>>.from(res.data['predictions']);
      }
      return [];
    } catch (e) {
      print('[AiController] getLatestPredictions Error: $e');
      return [];
    }
  }
}
