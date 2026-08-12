// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'sse_client.dart';

class SseClientImpl implements SseClient {
  final String url;
  final List<String> eventTypes;
  late final html.EventSource _eventSource;
  late final StreamController<SseEvent> _controller;

  SseClientImpl(this.url, {List<String>? eventTypes})
      : eventTypes = eventTypes ?? ['message'] {
    _controller = StreamController<SseEvent>();
    _eventSource = html.EventSource(url);

    _controller.onCancel = () => close();

    for (final eventType in this.eventTypes) {
      _eventSource.addEventListener(eventType, (event) {
        if (event is html.MessageEvent) {
          _controller.add(SseEvent(
            id: event.lastEventId,
            event: eventType,
            data: event.data.toString(),
          ));
        }
      });
    }
  }

  @override
  Stream<SseEvent> get stream => _controller.stream;

  @override
  void close() {
    _eventSource.close();
    _controller.close();
  }
}
