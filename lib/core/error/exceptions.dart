class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'An error occurred with the server response',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Network connection disconnected',
  });

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Failed to access local storage',
  });

  @override
  String toString() => 'CacheException: $message';
}
