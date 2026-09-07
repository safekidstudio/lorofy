import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feedback_service.dart';
import 'ui_feedback_service_impl.dart';

/// Riverpod provider for [FeedbackService].
/// Allows Dependency Injection across presentation components and test mocking.
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  // Can be overridden in ProviderScope during app initialization
  return UIFeedbackServiceImpl();
});
