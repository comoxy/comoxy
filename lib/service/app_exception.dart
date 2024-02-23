import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rate_review/util/string_resource.dart';

class AppException implements Exception {
  final _status;
  final _message;
  final _prefix;

  AppException([this._status, this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, resource.errorDuringCommunication.tr);
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(false, message, resource.invalidRequest.tr);
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(false, message, resource.unauthorised.tr);
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(false, message, resource.invalidInput.tr);
}
class NotFoundException extends AppException {
  NotFoundException([String? message]) : super(false, message, resource.notFoundException.tr);
}