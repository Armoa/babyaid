import 'package:babyaid/provider/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_interceptor.dart';

class HttpClient {
  static Dio getDio(BuildContext context) {
    final dio = Dio();

    // Aquí obtenemos una instancia de AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Agregamos el interceptor
    dio.interceptors.add(
      AuthInterceptor(
        dio,
        // Pasamos la función del AuthProvider al interceptor
        () => authProvider.handleTokenExpired(context),
      ),
    );

    return dio;
  }
}
