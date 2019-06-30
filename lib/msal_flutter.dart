import 'dart:async';

import 'package:flutter/services.dart';


class PublicClientApplication
{
  static const MethodChannel _channel =
      const MethodChannel('msal_flutter');

  static Future<String> acquireToken(List<String> scopes) async {
    final String token = await _channel.invokeMethod('acquireToken', scopes);
    return token;
  }

  static Future<String> acquireTokenSilent(List<String> scopes) async {
    final String token = await _channel.invokeMethod('acquireTokenSilent', scopes);
    return token; 
  }
}
