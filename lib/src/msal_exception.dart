class MsalException implements Exception {
  final String errorMessage;

  const MsalException(this.errorMessage);
}

class MsalChangedClientIdException extends MsalException {
  const MsalChangedClientIdException()
      : super("Cannot create a client with a new client ID. "
            "Only 1 client id supported");

  static MsalChangedClientIdException create() =>
      const MsalChangedClientIdException();
}

class MsalUserCancelledException extends MsalException {
  const MsalUserCancelledException() : super("User cancelled login request");

  static MsalUserCancelledException create() =>
      const MsalUserCancelledException();
}

class MsalNoAccountException extends MsalException {
  const MsalNoAccountException()
      : super("Cannot login silently. No account available");

  static MsalNoAccountException create() =>
      const MsalNoAccountException();
}

class MsalInvalidConfigurationException extends MsalException {
  const MsalInvalidConfigurationException(String errorMessage) : super(errorMessage);

  static MsalInvalidConfigurationException create(String errorMessage) =>
      MsalInvalidConfigurationException(errorMessage);
}

class MsalInvalidScopeException extends MsalException {
  const MsalInvalidScopeException() : super("Invalid or no scope");

  static MsalInvalidScopeException create() =>
      const MsalInvalidScopeException();
}

class MsalInitializationException extends MsalException {
  const MsalInitializationException()
      : super("Error initializing client. Please ensure "
            "correctly configuration supplied");

  static MsalInitializationException create() =>
      const MsalInitializationException();
}

class MsalUninitializedException extends MsalException {
  const MsalUninitializedException()
      : super("Client not initialized. Client "
            "must be initialized before attempting to use");

  static MsalUninitializedException create() =>
      const MsalUninitializedException();
}
