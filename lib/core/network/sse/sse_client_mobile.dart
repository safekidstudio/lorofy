import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'sse_client.dart';

class SseClientImpl implements SseClient {
  final String url;
  final List<String> eventTypes;
  final StreamController<SseEvent> _controller;
  final HttpClient _client;

  SseClientImpl(this.url, {List<String>? eventTypes})
      : eventTypes = eventTypes ?? ['message'],
        _controller = StreamController<SseEvent>(),
        _client = HttpClient() {
    _controller.onCancel = () => close();
    _connect();
  }

  void _connect() {
    _client.getUrl(Uri.parse(url)).then((request) {
      return request.close();
    }).then((response) {
      String lastEvent = 'message';
      String lastId = '';

      response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.isEmpty) return;
        if (line.startsWith('id:')) {
          lastId = line.substring(3).trim();
        } else if (line.startsWith('event:')) {
          lastEvent = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          if (eventTypes.contains(lastEvent)) {
            _controller.add(SseEvent(
              id: lastId.isEmpty ? null : lastId,
              event: lastEvent,
              data: data,
            ));
          }
        }
      }, onError: (e) {
        _controller.addError(e);
      }, onDone: () {
        _controller.close();
      });
    }).catchError((e) {
      _controller.addError(e);
    });
  }

  @override
  Stream<SseEvent> get stream => _controller.stream;

  @override
  void close() {
    _client.close();
    _controller.close();
  }
}
