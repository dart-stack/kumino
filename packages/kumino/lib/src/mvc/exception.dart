import 'dart:io';

class HttpException implements Exception {
  HttpException({
    this.statusCode = HttpStatus.internalServerError,
    this.message,
  });

  final int statusCode;

  final Object? message;
}
