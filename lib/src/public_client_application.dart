import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'msal_exception.dart';

/// Represents a PublicClientApplication used to authenticate using the implicit flow
@immutable
class PublicClientApplication {
  static const MethodChannel _channel = const MethodChannel('msal_flutter');

  final String _clientId;
  final String? _authority;

  const PublicClientApplication._create(this._clientId, {String? authority})
      : _authority = authority;

  static Future<PublicClientApplication> createPublicClientApplication(
    String clientId, {
    String? authority,
  }) async {
    final res = PublicClientApplication._create(clientId, authority: authority);
    await res._initialize();
    return res;
  }

  /// Acquire a token interactively for the given [scopes]
  Future<String> acquireToken(List<String> scopes) =>
      _invokePlatformMethod<String>('acquireToken', {'scopes': scopes});

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  Future<String> acquireTokenSilent(List<String> scopes) =>
      _invokePlatformMethod('acquireTokenSilent', {'scopes': scopes});

  Future<void> logout() => _invokePlatformMethod('logout');

  // initialize the main client platform side
  Future<void> _initialize() async => _invokePlatformMethod(
        'initialize',
        <String, dynamic>{
          'clientId': this._clientId,
          //if authority has been set, add it as well
          if (this._authority != null) 'authority': this._authority
        },
      );

  Future<T> _invokePlatformMethod<T>(String method,
      [Map<String, dynamic> arguments = const {}]) async {
    try {
      return await _channel.invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  static final _exceptionMapping = <String, MsalException Function()>{
    "CANCELLED": MsalUninitializedException.create,
    "NO_SCOPE": MsalInvalidScopeException.create,
    "NO_ACCOUNT": MsalNoAccountException.create,
    "NO_CLIENT": MsalUninitializedException.create,
    "CHANGED_CLIENTID": MsalChangedClientIdException.create,
    "INIT_ERROR": MsalInitializationException.create,
    "NO_CLIENTID": () => MsalInvalidConfigurationException("Client Id not set"),
    "INVALID_AUTHORITY": () =>
        MsalInvalidConfigurationException("Invalid authroity set."),
    "CONFIG_ERROR": () => MsalInvalidConfigurationException(
        "Invalid configuration, please correct your settings and try again"),
  };

  MsalException _convertException(PlatformException e) =>
      _exceptionMapping[e.code]?.call() ??
      MsalException("Authentication error");
}
