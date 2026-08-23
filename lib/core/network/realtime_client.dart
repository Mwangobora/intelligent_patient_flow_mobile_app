import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';
import 'api_client.dart';

class RealtimeClient {
  const RealtimeClient(this._apiClient);

  final ApiClient _apiClient;

  Future<WebSocketChannel> connect(String path) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${AppConstants.wsBaseUrl}$normalizedPath');
    final cookieHeader = await _apiClient.cookieHeaderFor(
      Uri.parse(AppConstants.apiBaseUrl),
    );

    _debugLog('connect $uri');
    return IOWebSocketChannel.connect(
      uri,
      headers: cookieHeader.isEmpty ? null : {'Cookie': cookieHeader},
    );
  }

  void _debugLog(String message) {
    if (kDebugMode) debugPrint('[realtime] $message');
  }
}
