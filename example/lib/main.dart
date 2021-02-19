import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msal_flutter/msal_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = 'NONE';

  PublicClientApplication pca;

  Future<void> _acquireToken() async {
    if (pca == null) {
      pca = await PublicClientApplication.createPublicClientApplication(
        "877c0662-a3da-40a3-ac5b-c72dee4b7b49",
        "msauth.uk.co.moodio.msalflutterr://auth",
        authority: "https://login.microsoftonline.com/consumers",
      );
    }

    String res;
    try {
      res = await pca.acquireToken(["user.read"]);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token. Unspecified reason";
    }

    setState(() {
      _output = res;
    });
  }

  Future<void> _acquireTokenSilently() async {
    if (pca == null) {
      pca = await PublicClientApplication.createPublicClientApplication(
        "877c0662-a3da-40a3-ac5b-c72dee4b7b49",
        "msauth.uk.co.moodio.msalflutterr://auth",
        authority: "https://login.microsoftonline.com/consumers",
      );
    }

    String res;
    try {
      res = await pca.acquireTokenSilent(["user.read"]);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token silently!";
    }

    setState(() {
      _output = res;
    });
  }

  Future _logout() async {
    print("called logout");
    if (pca == null) {
      pca = await PublicClientApplication.createPublicClientApplication(
        "877c0662-a3da-40a3-ac5b-c72dee4b7b49",
        "msauth.uk.co.moodio.msalflutterr://auth",
        authority: "https://login.microsoftonline.com/consumers",
      );
    }

    print("pca is not null");
    String res;
    try {
      await pca.logout();
      res = "Account removed";
    } on MsalException {
      res = "Error signing out";
    } on PlatformException catch (e) {
      res = "some other exception ${e.toString()}";
    }

    print("setting state");
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
              RaisedButton(
                onPressed: _acquireToken,
                child: Text('AcquireToken()'),
              ),
              RaisedButton(
                  onPressed: _acquireTokenSilently,
                  child: Text('AcquireTokenSilently()')),
              RaisedButton(onPressed: _logout, child: Text('Logout')),
              Text(_output),
            ],
          ),
        ),
      ),
    );
  }
}
