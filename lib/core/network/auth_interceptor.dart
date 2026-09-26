import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Intercepteur Dio responsable de :
/// 1. Injecter le token JWT (access token) de l'utilisateur connecté
///   dans l'en-tête Authorization de CHAQUE requête sortante.
/// 2. Détecter une expiration de token (erreur 401), déclencher un
///   rafraîchissement via le refresh token géré par Supabase, puis
///   rejouer automatiquement la requête initiale avec le nouveau token.
class AuthInterceptor extends Interceptor {
  final SupabaseClient supabaseClient;
  final Dio dio;
  final String anonKey;

  AuthInterceptor({
    required this.supabaseClient,
    required this.dio,
    required this.anonKey,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = supabaseClient.auth.currentSession?.accessToken;

    // La clé anon est requise par l'API Supabase en plus du JWT utilisateur.
    options.headers['apikey'] = anonKey;
    options.headers['Content-Type'] = 'application/json';

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;

    if (isUnauthorized) {
      try {
        // Tente de rafraîchir la session via le refresh token stocké
        // localement par supabase_flutter.
        final refreshed = await supabaseClient.auth.refreshSession();
        final newAccessToken = refreshed.session?.accessToken;

        if (newAccessToken != null) {
          // Rejoue la requête initiale avec le nouveau token, de façon
          // totalement transparente pour l'appelant.
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final response = await dio.fetch(retryOptions);
          return handler.resolve(response);
        }
      } catch (_) {
        // Le refresh a échoué (session totalement expirée) :
        // l'erreur 401 originale remonte normalement, l'utilisateur
        // devra se reconnecter.
      }
    }

    handler.next(err);
  }
}
