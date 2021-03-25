import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:msal_flutter/msal_flutter.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  static const String _authority = "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize";
  static const String _clientId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
  
  String _output = 'NONE';
  static const List<String> kScopes = [
    "https://graph.microsoft.com/user.read",
    "https://graph.microsoft.com/Calendars.ReadWrite",
  ];

  PublicClientApplication pca;

  Future<void> _acquireToken() async{
    if(pca == null){
      pca = await PublicClientApplication.createPublicClientApplication(_clientId, authority: _authority);
    }

    String res;
    try{
      res = await pca.acquireToken(kScopes);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    }on MsalException {
      res = "Error getting token. Unspecified reason";
    }

    setState(() {
      _output = res;
    });
  }

  Future<void> _acquireTokenSilently() async {
    if(pca == null){
      pca = await PublicClientApplication.createPublicClientApplication(_clientId, authority: _authority);
    }
    
    String res;
    try
    {
      res = await pca.acquireTokenSilent(kScopes);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException catch (e) {
      res = "Invalid scope: ${e.errorMessage}";
    }on MsalException {
      res = "Error getting token silently!";
    }

    setState(() {
      _output = res;
    });
  }

  Future _logout() async {
    print("called logout");
    if(pca == null){
      pca = await PublicClientApplication.createPublicClientApplication(_clientId, authority: _authority);
    }

    print("pca is not null");
    String res;
    try{
      await pca.logout();
      res = "Account removed";
    } on MsalException {
      res = "Error signing out";
    } on PlatformException catch (e){
      res = "some other exception ${e.toString()}";
    }

    print("setting state");
    setState((){
      _output = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton( onPressed: _acquireToken, 
                child: Text('AcquireToken()'),),
              RaisedButton( onPressed: _acquireTokenSilently,
                child: Text('AcquireTokenSilently()')),
              RaisedButton( onPressed: _logout,
                child: Text('Logout')),
              Text( _output),
            ],
          ),
        ),
      ),
    );
  }
}
