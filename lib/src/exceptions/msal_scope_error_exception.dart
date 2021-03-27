import 'package:msal_flutter/msal_flutter.dart';

class MsalScopeErrorException extends MsalException {
  MsalScopeErrorException() : super("Scope error or scope declined");
}
