class MsalException implements Exception {
  String errorMessage;
  MsalException(this.errorMessage);
}

class MsalChangedClientIdException extends MsalException {
  MsalChangedClientIdException()
      : super(
            "Cannot create a client with a new client ID. Only 1 client id supported");
}

class MsalUserCancelledException extends MsalException {
  MsalUserCancelledException() : super("User cancelled login request");
}

class MsalNoAccountException extends MsalException {
  MsalNoAccountException()
      : super("Cannot login silently. No account available");
}

class MsalInvalidConfigurationException extends MsalException {
  MsalInvalidConfigurationException(errorMessage) : super(errorMessage);
}

class MsalInvalidScopeException extends MsalException {
  MsalInvalidScopeException() : super("Invalid or no scope");
}

class MsalInitializationException extends MsalException {
  MsalInitializationException()
      : super(
            "Error initializing client. Please ensure correctly configuration supplied");
}

class MsalUninitializedException extends MsalException {
  MsalUninitializedException()
      : super(
            "Client not initialized. Client must be initialized before attempting to use");
}
