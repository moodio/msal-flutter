import 'msal_exception.dart';

class MsalInitializationException extends MsalException {
  MsalInitializationException()
      : super(
            "Error initializing client. Please ensure correctly configuration supplied");
}
