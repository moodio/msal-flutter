import 'MsalException.dart';

class MsalUninitializedException extends MsalException {
  MsalUninitializedException()
      : super(
            "Client not initialized. Client must be initialized before attempting to use");
}
