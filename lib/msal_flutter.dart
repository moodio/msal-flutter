import 'dart:async';

import 'package:flutter/services.dart';


class PublicClientApplication
{
  static const MethodChannel _channel =
      const MethodChannel('msal_flutter');

  static Future<String> acquireToken(String authority, String clientId, List<String> scopes) async 
  {

    final String token = await _channel.invokeMethod('acquireToken', <String,dynamic>{
      'scopes': scopes,
      'clientId': clientId,
      'authority': authority
    });
    return token;
  }

  static Future<String> acquireTokenSilent(String authority, String clientId, List<String> scopes) async {
    final String token = await _channel.invokeMethod('acquireTokenSilent', <String,dynamic>{
      'scopes': scopes,
      'clientId': clientId,
      'authority': authority
    });
    return token; 
  }
}
