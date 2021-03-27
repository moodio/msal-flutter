import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:msal_flutter/src/exceptions/msal_scope_error_exception.dart';
import 'exceptions/msal_exceptions.dart';

/// Represents a PublicClientApplication used to authenticate using the implicit flow
class PublicClientApplication {
  static const MethodChannel _channel = const MethodChannel('msal_flutter');

  String _clientId, _authority, _redirectUri;

  /// Create a new PublicClientApplication authenticating as the given [clientId],
  /// optionally select a [authority], defaulting to the common
  PublicClientApplication(String clientId, {String authority}) {
    throw Exception(
        "Direct call is no longer supported in v1.0, please use static method createPublicClientApplication");
  }

  PublicClientApplication._create(String clientId,
      {String authority, String redirectUri}) {
    _clientId = clientId;
    _authority = authority;
    _redirectUri = redirectUri;
  }

  ///
  /// @param clientId The id of the client, as registered in Azure AD
  /// @param authority The authority to authenticate against
  /// @param redirectUri The redirect uri registered for your application for all platforms
  /// @param androidRedirectUri Override for android specific redirectUri
  /// @param iosRedirectUri Override for iOS specific redirectUri
  static Future<PublicClientApplication> createPublicClientApplication(
      String clientId,
      {String authority,
      String redirectUri,
      String androidRedirectUri,
      String iosRedirectUri}) async {
    //set the correct redirect uri based on platform
    if (Platform.isAndroid && androidRedirectUri != null) {
      redirectUri = androidRedirectUri;
    } else if (Platform.isIOS && iosRedirectUri != null) {
      redirectUri = iosRedirectUri;
    }

    var res = PublicClientApplication._create(clientId,
        authority: authority, redirectUri: redirectUri);
    await res._initialize();
    return res;
  }

  /// Acquire a token interactively for the given [scopes]
  Future<String> acquireToken(List<String> scopes) async {
    print("Called acquiretoken");
    //create the arguments
    var res = <String, dynamic>{'scopes': scopes};
    //call platform
    try {
      final String token = await _channel.invokeMethod('acquireToken', res);
      return token;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  Future<String> acquireTokenSilent(List<String> scopes) async {
    //create the arguments
    var res = <String, dynamic>{'scopes': scopes};

    //call platform
    try {
      final String token =
          await _channel.invokeMethod('acquireTokenSilent', res);
      return token;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  Future logout() async {
    try {
      await _channel.invokeMethod('logout', <String, dynamic>{});
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  MsalException _convertException(PlatformException e) {
    switch (e.code) {
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
        return MsalInvalidConfigurationException(
            "Invalid configuration, please correct your settings and try again");
      case "NO_CLIENT":
        return MsalUninitializedException();
      case "CHANGED_CLIENTID":
        return MsalChangedClientIdException();
      case "INIT_ERROR":
        return MsalInitializationException();
      case "SCOPE_ERROR":
        return MsalScopeErrorException();
      case "AUTH_ERROR":
      default:
        return MsalException("Authentication error");
    }
  }

  //initialize the main client platform side
  Future _initialize() async {
    var res = <String, dynamic>{'clientId': this._clientId};
    //if authority has been set, add it aswell
    if (this._authority != null) {
      res["authority"] = this._authority;
    }

    if (this._redirectUri != null) {
      res["redirectUri"] = this._redirectUri;
    }

    try {
      await _channel.invokeMethod('initialize', res);
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }
}
