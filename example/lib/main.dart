import 'package:flutter/material.dart';
import 'dart:async';
import 'package:msal_flutter/msal_flutter.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = 'NONE';

  PublicClientApplication pca;

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    pca = PublicClientApplication("5913dfb1-7576-451c-a7ea-a7c5a3f8682a", authority: "https://login.microsoftonline.com/tfp/msalfluttertest.onmicrosoft.com/B2C_1_sisu");
  }

  Future<void> _acquireToken() async{
    String res;
    try{
      res = await pca.acquireToken(["https://msalfluttertest.onmicrosoft.com/msalbackend/user_impersonation"]);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    }on MsalException {
      res = "Error getting token silently!";
    }

    setState(() {
      _output = res;
    });
  }

  Future<void> _acquireTokenSilently() async {
    String res;
    try
    {
      res = await pca.acquireTokenSilent(["https://msalfluttertest.onmicrosoft.com/msalbackend/user_impersonation"]);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    }on MsalException {
      res = "Error getting token silently!";
    }

    setState(() {
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
              Text( _output)
            ],
          ),
        ),
      ),
    );
  }
}
