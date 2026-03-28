import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionException, PostgrestException, StorageException;

enum ErrorType {
  noInternet, // Pas de connexion internet
  timeout, // Délai d'attente dépassé
  serverError, // Erreur 500+
  badRequest, // Erreur 400-499
  duplicate, // Doublon (contrainte unique)
  unknown // Autre erreur
}

class ErrorHandler {
  static Map<String, dynamic>? _tryParseJsonFromString(String input) {
    final start = input.indexOf('{');
    final end = input.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;

    final slice = input.substring(start, end + 1);
    try {
      final decoded = jsonDecode(slice);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // ignore
    }
    return null;
  }

  static Map<String, dynamic>? _extractEdgePayload(dynamic error) {
    if (error is! FunctionException) return null;

    final details = error.details;
    if (details is Map) {
      return details.map((k, v) => MapEntry(k.toString(), v));
    }

    if (details is String) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        // ignore
      }
    }

    return null;
  }

  static String? _messageFromEdgePayload(Map<String, dynamic> payload) {
    final m = (payload['error'] ?? payload['message'] ?? '').toString().trim();
    final hint = (payload['hint'] ?? '').toString().trim();
    final field = (payload['field'] ?? '').toString().trim();
    if (m.isEmpty) return null;
    var out = hint.isNotEmpty ? '$m\n$hint' : m;
    if (field.isNotEmpty && !m.contains(field)) {
      out = '$out\n($field)';
    }
    return out;
  }

  static String? _extractReadableExceptionMessage(dynamic error) {
    final raw = error.toString().trim();
    if (raw.isEmpty) return null;

    // Sometimes the JSON payload is embedded in the error string.
    final embedded = _tryParseJsonFromString(raw);
    if (embedded != null) {
      final message = (embedded['error'] ?? '').toString().trim();
      final hint = (embedded['hint'] ?? '').toString().trim();
      if (message.isNotEmpty) return hint.isNotEmpty ? '$message\n$hint' : message;
    }

    final cleaned = raw.replaceFirst(RegExp(r'^(Exception|Error):\s*'), '').trim();
    if (cleaned.isEmpty) return null;

    // Only surface if it looks like a user-facing message (avoid dumping technical errors).
    final lower = cleaned.toLowerCase();
    final looksUserFacing = lower.contains('champ') ||
        lower.contains('inscription') ||
        lower.contains('données') ||
        lower.contains('formulaire') ||
        lower.contains('base de données') ||
        lower.contains('email') ||
        lower.contains('téléphone') ||
        lower.contains('telephone') ||
        lower.contains('photo') ||
        lower.contains('rgpd');

    if (looksUserFacing && cleaned.length <= 400) return cleaned;
    return null;
  }

  /// Parse une exception et retourne un message amical.
  static String getFriendlyMessage(dynamic error) {
    if (error is TypeError) {
      final t = error.toString();
      if (t.contains('subtype') && t.contains('null')) {
        return 'Données reçues incomplètes.\nRéessayez ou contactez le support.';
      }
    }

    if (error is StorageException) {
      final raw = error.message.trim();
      final alt = (error.error ?? '').toString().trim();
      final text = raw.isNotEmpty ? raw : alt;
      if (text.isNotEmpty) {
        final lower = text.toLowerCase();
        if (lower.contains('network') ||
            lower.contains('socket') ||
            lower.contains('failed host lookup') ||
            lower.contains('connection')) {
          return 'Pas de connexion internet.\nVérifiez votre réseau et réessayez.';
        }
        return text.length <= 400 ? text : '${text.substring(0, 397)}...';
      }
    }

    if (error is PostgrestException) {
      final base = error.message.trim();
      final hint = (error.hint ?? '').toString().trim();
      if (base.isNotEmpty) {
        final out = hint.isNotEmpty ? '$base\n$hint' : base;
        return out.length <= 400 ? out : '${out.substring(0, 397)}...';
      }
    }

    final payload = _extractEdgePayload(error);
    if (payload != null) {
      final fromPayload = _messageFromEdgePayload(payload);
      if (fromPayload != null) return fromPayload;
    }

    final readable = _extractReadableExceptionMessage(error);
    if (readable != null) return readable;

    final errorType = _detectErrorType(error);
    switch (errorType) {
      case ErrorType.noInternet:
        return 'Pas de connexion internet.\nVérifiez votre réseau et réessayez.';
      case ErrorType.timeout:
        return 'Connexion trop lente.\nVérifiez votre réseau et réessayez.';
      case ErrorType.duplicate:
        return 'Cette inscription existe déjà.\nVérifiez vos données ou contactez le support.';
      case ErrorType.badRequest:
        return 'Données invalides.\nVérifiez le formulaire et réessayez.';
      case ErrorType.serverError:
        return 'Erreur serveur temporaire.\nRéessayez dans quelques instants.';
      case ErrorType.unknown:
        return 'Une erreur est survenue.\nRéessayez ou contactez le support.';
    }
  }

  /// Détecte le type d'erreur.
  static ErrorType _detectErrorType(dynamic error) {
    final payload = _extractEdgePayload(error);
    if (error is FunctionException && payload != null) {
      final errorCode = (payload['error_code'] ?? payload['code'] ?? '').toString();
      if (error.status == 409 && errorCode.toUpperCase() == 'DUPLICATE') {
        return ErrorType.duplicate;
      }
      if (error.status >= 500) return ErrorType.serverError;
      if (error.status >= 400) return ErrorType.badRequest;
    }

    final errorStr = error.toString().toLowerCase();

    if (error is SocketException ||
        errorStr.contains('no internet') ||
        errorStr.contains('network') ||
        errorStr.contains('failed to fetch') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('connection timeout')) {
      return ErrorType.noInternet;
    }

    if (errorStr.contains('timeout') ||
        errorStr.contains('timed out') ||
        errorStr.contains('deadline exceeded')) {
      return ErrorType.timeout;
    }

    if (errorStr.contains('duplicate key') || errorStr.contains('23505')) {
      return ErrorType.duplicate;
    }

    if (errorStr.contains('400 (bad request)') ||
        errorStr.contains('bad request') ||
        errorStr.contains('invalid') ||
        errorStr.contains('403') ||
        errorStr.contains('404') ||
        (errorStr.contains('status:') &&
            (errorStr.contains('400') ||
                errorStr.contains('401') ||
                errorStr.contains('403') ||
                errorStr.contains('404')))) {
      return ErrorType.badRequest;
    }

    if (errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503') ||
        errorStr.contains('server error') ||
        errorStr.contains('internal error')) {
      return ErrorType.serverError;
    }

    return ErrorType.unknown;
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}

