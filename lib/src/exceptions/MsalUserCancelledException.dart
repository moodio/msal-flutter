import 'msal_exceptions.dart';

class MsalUserCancelledException extends MsalException {
  MsalUserCancelledException() : super("User cancelled login request");
}
