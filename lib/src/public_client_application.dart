import 'dart:async';
import 'package:flutter/services.dart';
import 'msal_exception.dart';

/// Represents a PublicClientApplication used to authenticate using the implicit flow
class PublicClientApplication {
  static const MethodChannel _channel = const MethodChannel('msal_flutter');

  String _clientId, _authority;

  /// Create a new PublicClientApplication authenticating as the given [clientId],
  /// optionally against the selected [authority], defaulting to the common
  PublicClientApplication(String clientId, {String authority}) {
    this._clientId = clientId;
    this._authority = authority;
  }

  /// Acquire a token interactively for the given [scopes]
  Future<String> acquireToken(List<String> scopes) async {
    try {
      final String token = await _channel.invokeMethod(
          'acquireToken', _createMethodcallArguments(scopes));
      return token;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  Future<String> acquireTokenSilent(List<String> scopes) async {
    try {
      final String token = await _channel.invokeMethod(
          'acquireTokenSilent', _createMethodcallArguments(scopes));
      return token;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  /// Creates the arguments Map used for calling the platform channel methods
  Map<String, dynamic> _createMethodcallArguments(List<String> scopes) {
    //create the map with the key properties
    var res = <String, dynamic>{'scopes': scopes, 'clientId': this._clientId};

    //if authority has been set, add it aswell
    if (this._authority != null) {
      res["authority"] = this._authority;
    }

    //return the new map
    return res;
  }

  MsalException _convertException(PlatformException e)
  {
    switch(e.code)
    {
      case "CANCELLED":
        return MsalUserCancelledException();
      case "NO_SCOPE":
        return MsalInvalidScopeException();
      case "NO_ACCOUNT":
        return MsalNoAccountException();
      case "NO_CLIENTID":
        return MsalInvalidConfigurationException("Client Id not set");
      case "INVALID_AUTHORITY":
        return MsalInvalidConfigurationException("Invalid authroity set.");
      case "CONFIG_ERROR":
        return MsalInvalidConfigurationException("Invalid configuration, please correct your settings and try again");
      case "AUTH_ERROR":
      default:
        return MsalException("Authentication error");

    }

  }
}
