import 'dart:async';

/// Retry helper avec backoff exponentiel
class RetryHelper {
  /// Réessaye une fonction avec backoff exponentiel
  /// 
  /// [fn]: La fonction à exécuter
  /// [maxAttempts]: Nombre max de tentatives (par défaut 3)
  /// [initialDelay]: Délai initial entre tentatives en ms (par défaut 1000)
  /// [maxDelay]: Délai max entre tentatives en ms (par défaut 10000)
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
    int initialDelay = 1000,
    int maxDelay = 10000,
  }) async {
    int attempt = 0;
    int delay = initialDelay;

    while (true) {
      try {
        attempt++;
        return await fn();
      } catch (e) {
        if (attempt >= maxAttempts) {
          rethrow;
        }
        
        // Backoff exponentiel: 1s, 2s, 4s...
        await Future.delayed(Duration(milliseconds: delay));
        delay = (delay * 2).clamp(initialDelay, maxDelay);
      }
    }
  }

  /// Réessaye avec condition personnalisée
  /// [shouldRetry]: Fonction qui retourne true si on doit réessayer
  static Future<T> retryIf<T>(
    Future<T> Function() fn, {
    required bool Function(dynamic error) shouldRetry,
    int maxAttempts = 3,
    int initialDelay = 1000,
    int maxDelay = 10000,
  }) async {
    int attempt = 0;
    int delay = initialDelay;

    while (true) {
      try {
        attempt++;
        return await fn();
      } catch (e) {
        if (attempt >= maxAttempts || !shouldRetry(e)) {
          rethrow;
        }
        
        await Future.delayed(Duration(milliseconds: delay));
        delay = (delay * 2).clamp(initialDelay, maxDelay);
      }
    }
  }
}
