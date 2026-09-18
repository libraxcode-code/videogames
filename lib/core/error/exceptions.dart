class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Terjadi kesalahan pada respon server',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Koneksi jaringan terputus',
  });

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Gagal mengakses penyimpanan lokal',
  });

  @override
  String toString() => 'CacheException: $message';
}
