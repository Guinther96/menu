import 'package:dio/dio.dart';

class AppException implements Exception {
  AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return AppException('Le serveur met trop de temps à répondre.');
    case DioExceptionType.connectionError:
      return AppException('Impossible de contacter le serveur.');
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      return AppException('Erreur serveur (${code ?? 'inconnue'}).');
    default:
      return AppException('Une erreur inattendue est survenue.');
  }
}
