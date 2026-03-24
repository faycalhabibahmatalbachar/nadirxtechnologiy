import 'dart:io';
import 'package:flutter/foundation.dart';

enum ErrorType {
  noInternet,      // Pas de connexion internet
  timeout,         // Délai d'attente dépassé
  serverError,     // Erreur 500+
  badRequest,      // Erreur 400-499
  duplicateEmail,  // Email en doublon
  unknown          // Autre erreur
}

class ErrorHandler {
  /// Parse une exception et retourne un message amical
  static String getFriendlyMessage(dynamic error) {
    final errorType = _detectErrorType(error);
    
    switch (errorType) {
      case ErrorType.noInternet:
        return 'Pas de connexion internet.\nVérifiez votre réseau et réessayez.';
      case ErrorType.timeout:
        return 'Connexion trop lente.\nVérifiez votre réseau et réessayez.';
      case ErrorType.duplicateEmail:
        return 'Cet email est déjà utilisé.\nEntrez un autre email ou contactez le support.';
      case ErrorType.badRequest:
        return 'Données invalides.\nVérifiez le formulaire et réessayez.';
      case ErrorType.serverError:
        return 'Erreur serveur temporaire.\nRéessayez dans quelques instants.';
      case ErrorType.unknown:
      default:
        return 'Une erreur est survenue.\nRéessayez ou contactez le support.';
    }
  }

  /// Détecte le type d'erreur
  static ErrorType _detectErrorType(dynamic error) {
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

    // Email en doublon
    if (errorStr.contains('duplicate key') && errorStr.contains('email')) {
      return ErrorType.duplicateEmail;
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

  /// Vérifie s'il y a une connexion internet (simple check)
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
