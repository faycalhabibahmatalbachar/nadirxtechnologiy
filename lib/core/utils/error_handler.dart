import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

enum ErrorType {
  noInternet, // Pas de connexion internet
  timeout, // Délai d'attente dépassé
  serverError, // Erreur 500+
  badRequest, // Erreur 400-499
  duplicate, // Doublon (contrainte unique)
  unknown // Autre erreur
}

class ErrorHandler {
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

  /// Parse une exception et retourne un message amical.
  static String getFriendlyMessage(dynamic error) {
    final payload = _extractEdgePayload(error);
    if (payload != null) {
      final message = (payload['error'] ?? '').toString().trim();
      final hint = (payload['hint'] ?? '').toString().trim();

      if (message.isNotEmpty) {
        return hint.isNotEmpty ? '$message\n$hint' : message;
      }
    }

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

    // Erreur réseau
    if (error is SocketException ||
        errorStr.contains('no internet') ||
        errorStr.contains('network') ||
        errorStr.contains('failed to fetch') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('connection timeout')) {
      return ErrorType.noInternet;
    }

    // Timeout
    if (errorStr.contains('timeout') ||
        errorStr.contains('timed out') ||
        errorStr.contains('deadline exceeded')) {
      return ErrorType.timeout;
    }

    // Doublon (violation contrainte unique)
    if (errorStr.contains('duplicate key') || errorStr.contains('23505')) {
      return ErrorType.duplicate;
    }

    // Erreur 400-499
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

    // Erreur 500+
    if (errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503') ||
        errorStr.contains('server error') ||
        errorStr.contains('internal error')) {
      return ErrorType.serverError;
    }

    return ErrorType.unknown;
  }

  /// Vérifie s'il y a une connexion internet (simple check).
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

