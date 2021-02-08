import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:msal_flutter/models/authority.dart';
import 'package:msal_flutter/models/authorization_agent.dart';
import 'package:msal_flutter/models/browser_descriptor.dart';
import 'package:msal_flutter/models/environment.dart';
import 'package:msal_flutter/models/http_configuration.dart';
import 'package:msal_flutter/models/logger_configuration.dart';

import 'msal_exception.dart';

/// Represents a PublicClientApplication used to authenticate using the implicit flow
class PublicClientApplication {
  static const MethodChannel _channel = const MethodChannel('msal_flutter');

  // String _clientId, _authority;
  String clientID;

  String redirectUri;

  List<Authority> authority;

  HttpConfiguration httpConfiguration;

  AuthorizationAgent authorizationAgent = AuthorizationAgent.DEFAULT;

  LoggerConfiguration loggerConfiguration;

  bool multipleCloudsSupported;

  bool useBroker;

  Environment environment;

  String requiredBrokerProtocolVersion;

  String clientCapabilities;

  bool webViewZoomControlsEnabled;

  bool webViewZoomEnabled;

  bool powerOptCheckEnabled;

  List<BrowserDescriptor> browserDescriptor;

  List<String> jsonString = [];

  /// Create a new PublicClientApplication authenticating as the given [clientId],
  /// optionally against the selected [authority], defaulting to the common
  PublicClientApplication(String clientId, {String authority}) {
    throw Exception(
        "Direct call is no longer supported in v1.0, please use static method createPublicClientApplication");
  }

  PublicClientApplication._create(String clientID, String redirectUri,
      {List<Authority> authority,
      HttpConfiguration httpConfiguration,
      AuthorizationAgent authorizationAgent,
      LoggerConfiguration loggerConfiguration,
      bool multipleCloudsSupported,
      bool useBroker,
      Environment environment,
      String requiredBrokerProtocolVersion,
      String clientCapabilities,
      List<BrowserDescriptor> browserDescriptor,
      bool webViewZoomControlsEnabled,
      bool webViewZoomEnabled,
      bool powerOptCheckEnabled}) {
    this.clientID = clientID;
    this.redirectUri = redirectUri;
    this.httpConfiguration = httpConfiguration;
    this.authorizationAgent = authorizationAgent;
    this.authority = authority;
    this.browserDescriptor = browserDescriptor;
    this.loggerConfiguration = loggerConfiguration;
    this.multipleCloudsSupported = multipleCloudsSupported;
    this.useBroker = useBroker;
    this.environment = environment;
    this.requiredBrokerProtocolVersion = requiredBrokerProtocolVersion;
    this.clientCapabilities = clientCapabilities;
    this.webViewZoomControlsEnabled = webViewZoomControlsEnabled;
    this.webViewZoomEnabled = webViewZoomEnabled;
    this.powerOptCheckEnabled = powerOptCheckEnabled;
  }

  static Future<PublicClientApplication> createPublicClientApplication(
      String clientID, String redirectUri,
      {List<Authority> authority,
      HttpConfiguration httpConfiguration,
      AuthorizationAgent authorizationAgent = AuthorizationAgent.DEFAULT,
      LoggerConfiguration loggerConfiguration,
      bool multipleCloudsSupported,
      bool useBroker,
      List<BrowserDescriptor> browserDescriptor,
      Environment environment,
      String requiredBrokerProtocolVersion,
      String clientCapabilities,
      bool webViewZoomControlsEnabled,
      bool webViewZoomEnabled,
      bool powerOptCheckEnabled}) async {
    var res = PublicClientApplication._create(clientID, redirectUri,
        authorizationAgent: authorizationAgent,
        httpConfiguration: httpConfiguration,
        environment: environment,
        authority: authority,
        browserDescriptor: browserDescriptor,
        clientCapabilities: clientCapabilities,
        loggerConfiguration: loggerConfiguration,
        multipleCloudsSupported: multipleCloudsSupported,
        powerOptCheckEnabled: powerOptCheckEnabled,
        requiredBrokerProtocolVersion: requiredBrokerProtocolVersion,
        useBroker: useBroker,
        webViewZoomControlsEnabled: webViewZoomControlsEnabled,
        webViewZoomEnabled: webViewZoomEnabled);
    await res._initialize();
    return res;
  }

  /// Acquire a token interactively for the given [scopes]
  Future<String> acquireToken(List<String> scopes) async {
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
      case "NO_REDIRECTURI":
        return MsalInvalidConfigurationException("RedirectUri  not set");
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
      case "AUTH_ERROR":
      default:
        return MsalException("Authentication error");
    }
  }

  //initialize the main client platform side
  Future _initialize() async {
    var res = <String, dynamic>{};

    _getMSALConfiguration();

    res["jsonString"] = jsonString;

    try {
      await _channel.invokeMethod('initialize', res);
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  //method used to validate Configuration and return list of valid config.
  void _getMSALConfiguration() {
    //required
    if (clientID.replaceAll(" ", "").isEmpty) {
      throw _convertException(PlatformException(code: "NO_CLIENTID"));
    }

    if (redirectUri.replaceAll(" ", "").isEmpty) {
      throw _convertException(PlatformException(code: "NO_REDIRECTURI"));
    }

    jsonString.add("\"client_id\":" + "\"$clientID\"");
    jsonString.add("\"redirect_uri\":" + "\"$redirectUri\"");

    _addJsonItem(
        httpConfiguration, "\"http\":" + jsonEncode(httpConfiguration));
    _addJsonItem(
        authority, "\"authorities\":\n" + jsonEncode(authority));
    _addJsonItem(authorizationAgent,
        "\"authorization_user_agent\":" +   "\"${authorizationAgent.toString().split('.').last}\"");

    _addJsonItem(
        loggerConfiguration, "\"logging\":" + jsonEncode(loggerConfiguration));

    _addJsonItem(multipleCloudsSupported,
        "\"multiple_clouds_supported\":" + "$multipleCloudsSupported");
    _addJsonItem(
        useBroker, "\"broker_redirect_uri_registered\":" + "$useBroker");

    _addJsonItem(environment,
        "\"environment\":" + "\"${environment.toString().split('.').last}\"");

    _addJsonItem(
        requiredBrokerProtocolVersion,
        "\"minimum_required_broker_protocol_version\":" + "$requiredBrokerProtocolVersion");

    _addJsonItem(clientCapabilities,
        "\"client_capabilities\":" + "\"$clientCapabilities\"");

    _addJsonItem(webViewZoomControlsEnabled,
        "\"web_view_zoom_controls_enabled\":" + "$webViewZoomControlsEnabled");

    _addJsonItem(webViewZoomEnabled,
        "\"web_view_zoom_enabled\":" + "$webViewZoomEnabled");

    _addJsonItem(
        powerOptCheckEnabled,
        "\"power_opt_check_for_network_req_enabled\":" +
            "$powerOptCheckEnabled");

    jsonString.add("\"account_mode\": " + "\"MULTIPLE\"");
    _addJsonItem(browserDescriptor,
        "\"browser_safelist\":" + jsonEncode(browserDescriptor));

  }



  void _addJsonItem(Object object, String jsonItem) {
    if (object != null) {
      jsonString.add(jsonItem);
    }
  }

}
