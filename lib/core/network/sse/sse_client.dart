import 'sse_client_stub.dart'
    if (dart.library.html) 'sse_client_web.dart'
    if (dart.library.io) 'sse_client_mobile.dart';

abstract class SseClient {
  factory SseClient(String url, {List<String>? eventTypes}) = SseClientImpl;
  Stream<SseEvent> get stream;
  void close();
}

class SseEvent {
  final String? id;
  final String event;
  final String data;

  SseEvent({this.id, required this.event, required this.data});
}
