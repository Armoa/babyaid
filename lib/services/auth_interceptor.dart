import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Function onTokenExpired;

  AuthInterceptor(this.dio, this.onTokenExpired);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si la respuesta es 401 (Unauthorized)
    if (err.response?.statusCode == 401) {
      // Notifica a la UI que el token ha expirado
      onTokenExpired();
    }
    // Continúa con el flujo normal de errores
    return super.onError(err, handler);
  }
}
