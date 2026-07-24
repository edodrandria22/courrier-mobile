import 'dart:developer' as developer;

class AppLogger {
  /// Enregistre une erreur avec un message et le corps de la réponse
  static Future<void> error(String message, String body) async {
    developer.log(
      '❌ $message\nBody: $body',
      name: 'APP_ERROR',
    );
  }

  /// Enregistre une exception avec l'erreur et la trace d'exécution
  static void exception(String message, Object error, StackTrace stackTrace) {
    developer.log(
      '🚨 $message',
      error: error,
      stackTrace: stackTrace,
      name: 'APP_EXCEPTION',
    );
  }
}