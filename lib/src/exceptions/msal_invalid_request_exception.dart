import 'msal_exception.dart';

class MsalInvalidRequestException extends MsalException {
  MsalInvalidRequestException(errorMessage) : super(errorMessage);
}
