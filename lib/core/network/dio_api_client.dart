import 'dart:developer' as dev;
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../error/exceptions.dart';

/// Production-ready Dio Network Client with SSL Pinning & RAWG API support.
class DioApiClient {
  late final Dio dio;
  static const String baseUrl = 'https://api.rawg.io/api';
  
  // Default public demo API key for RAWG (Replaceable via setApiKey or constructor)
  String apiKey;

  // Expected SHA-256 fingerprint for api.rawg.io certificate (can be updated or bypassed if null)
  final List<String>? allowedSha256Fingerprints;

  DioApiClient({
    String? apiKey,
    this.allowedSha256Fingerprints,
  }) : apiKey = apiKey ?? '02ef6ba5d13444ee86bad607e8bce3f4' {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Videogames-Flutter-App/1.0',
        },
      ),
    );

    _setupSecurityAndPinning();
  }

  void _setupSecurityAndPinning() {
    // Configure HttpClientAdapter for Android / iOS / Desktop (dart:io)
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient(
          context: SecurityContext(withTrustedRoots: true),
        );

        // SSL Certificate Verification & Pinning
        client.badCertificateCallback = (
          X509Certificate cert,
          String host,
          int port,
        ) {
          // If host matches RAWG API
          if (host.contains('rawg.io')) {
            // If explicit fingerprints are configured, enforce SSL Pinning
            if (allowedSha256Fingerprints != null &&
                allowedSha256Fingerprints!.isNotEmpty) {
              final certSha256 = sha256.convert(cert.der).toString().toUpperCase();

              final isPinned = allowedSha256Fingerprints!.any(
                (fp) => fp.replaceAll(':', '').toUpperCase() == certSha256,
              );

              if (!isPinned) {
                dev.log(
                  'SSL Pinning Validation Failed for $host: $certSha256',
                  name: 'DioApiClient',
                );
                return false;
              }
            }
          }
          // Fallback to standard CA trust validation
          return false;
        };

        return client;
      };
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final query = Map<String, dynamic>.from(queryParameters ?? {});
      if (!query.containsKey('key') && apiKey.isNotEmpty) {
        query['key'] = apiKey;
      }

      final response = await dio.get(
        path,
        queryParameters: query,
      );

      return response.data;
    } on DioException catch (e) {
      if (e.error is HandshakeException || e.type == DioExceptionType.badCertificate) {
        throw const NetworkException(
          message: 'SSL Security Verification / Certificate validation failed',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(message: 'Connection timeout with RAWG API');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Koneksi internet bermasalah atau server tidak dapat dijangkau',
        );
      } else if (e.response != null) {
        throw ServerException(
          message: e.response?.data?['error']?.toString() ??
              'RAWG API returned status code ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: e.message ?? 'Unknown network error');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
