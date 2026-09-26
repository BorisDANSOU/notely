import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_interceptor.dart';

/// Construit le client Dio utilisé pour parler directement à l'API REST
/// (PostgREST) exposée par Supabase, avec l'intercepteur JWT/refresh
/// branché dessus.
class DioClient {
  DioClient._();

  static Dio create() {
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']!;

    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    dio.interceptors.add(
      AuthInterceptor(
        supabaseClient: Supabase.instance.client,
        dio: dio,
        anonKey: anonKey,
      ),
    );

    return dio;
  }
}
