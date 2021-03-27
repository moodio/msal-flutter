import 'msal_exceptions.dart';

class MsalNoAccountException extends MsalException {
  MsalNoAccountException()
      : super("Cannot login silently. No account available");
}
