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
    super.message = 'A server error occurred. Please try again.',
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Internet connection issue. Please check your network.',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to process local storage or cache.',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
  });
}
