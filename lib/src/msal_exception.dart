class MsalException implements Exception {
  String errorMessage;
  MsalException(this.errorMessage);
}

class MsalUserCancelledException extends MsalException {
  MsalUserCancelledException(): super("User cancelled login request");
}

class MsalNoAccountException extends MsalException
{
  MsalNoAccountException() : super("Cannot login silently. No account available");
}

class MsalInvalidConfigurationException extends MsalException
{
  MsalInvalidConfigurationException(errorMessage): super(errorMessage);
}

class MsalInvalidScopeException extends MsalException
{
  MsalInvalidScopeException() : super("Invalid or no scope");
}