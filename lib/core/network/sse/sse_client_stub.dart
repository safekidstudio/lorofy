import 'sse_client.dart';

class SseClientImpl implements SseClient {
  SseClientImpl(String url, {List<String>? eventTypes}) {
    throw UnsupportedError('Cannot create SSE client');
  }

  @override
  Stream<SseEvent> get stream => throw UnsupportedError('Cannot create SSE client');

  @override
  void close() {}
}
