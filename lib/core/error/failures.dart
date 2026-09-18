import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Terjadi kesalahan pada server. Silakan coba lagi.',
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Gagal memproses data lokal / cache.',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
  });
}
