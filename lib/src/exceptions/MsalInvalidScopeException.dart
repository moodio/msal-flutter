import 'MsalException.dart';

class MsalInvalidScopeException extends MsalException {
  MsalInvalidScopeException() : super("Invalid or no scope");
}
