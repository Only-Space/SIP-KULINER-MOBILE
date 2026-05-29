import 'dart:async';
import 'dart:io';

abstract class AppException implements Exception {
  final String message;
  final String prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() {
    return message;
  }
}

class NetworkException extends AppException {
  NetworkException([String message = 'Koneksi internet terputus. Periksa jaringan Anda.'])
      : super(message, 'Network Error');
}

class ServerException extends AppException {
  ServerException([String message = 'Server sedang bermasalah. Coba beberapa saat lagi.'])
      : super(message, 'Server Error');
}

class LocationException extends AppException {
  LocationException([String message = 'Gagal mendapatkan lokasi.'])
      : super(message, 'Location Error');
}

class AuthException extends AppException {
  AuthException([String message = 'Gagal melakukan otentikasi.'])
      : super(message, 'Auth Error');
}

AppException parseException(dynamic e) {
  if (e is SocketException) {
    return NetworkException();
  } else if (e is TimeoutException) {
    return NetworkException('Koneksi terlalu lambat. Coba lagi.');
  } else if (e is FormatException) {
    return ServerException('Terjadi kesalahan format data.');
  } else if (e.toString().contains('500') || e.toString().contains('502') || e.toString().contains('503') || e.toString().contains('504')) {
    return ServerException();
  } else if (e is AppException) {
    return e;
  }
  return ServerException(e.toString().replaceAll('Exception: ', ''));
}
