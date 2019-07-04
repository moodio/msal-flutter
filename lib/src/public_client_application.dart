import 'dart:async';
import 'package:flutter/services.dart';

/// Represents a PublicClientApplication used to authenticate using the implicit flow
class PublicClientApplication
{
  static const MethodChannel _channel =
      const MethodChannel('msal_flutter');

  String _clientId, _authority;

  PublicClientApplication(String clientId, {String authority})
  {
    this._clientId = clientId;
    this._authority = authority;
  }

  /// Acquire a token interactively for the given [scopes]
  Future<String> acquireToken(List<String> scopes) async 
  {
    final String token = await _channel.invokeMethod('acquireToken', _createMethodcallArguments(scopes));
    return token;
  }

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  Future<String> acquireTokenSilent(List<String> scopes) async {
    final String token = await _channel.invokeMethod('acquireTokenSilent', _createMethodcallArguments(scopes));
    return token; 
  }

  /// Creates the arguments Map used for calling the platform channel methods
  Map<String, dynamic> _createMethodcallArguments(List<String> scopes)
  {  
    //create the map with the key properties
    var res = <String,dynamic>{
      'scopes': scopes,
      'clientId': this._clientId
    };

    //if authority has been set, add it aswell
    if(this._authority!=null){
      res["authority"] = this._authority;
    }

    //return the new map
    return res;
    
  }
}
