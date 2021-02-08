import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msal_flutter/models/audience.dart';
import 'package:msal_flutter/models/authority.dart';
import 'package:msal_flutter/models/authority_type.dart';
import 'package:msal_flutter/models/microsfot_account.dart';
import 'package:msal_flutter/msal_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _authority =
      "https://msalfluttertest.b2clogin.com/tfp/msalfluttertest.onmicrosoft.com/B2C_1_sisu";
  static const String _clientId = "5913dfb1-7576-451c-a7ea-a7c5a3f8682a";

  String _output = 'NONE';

  PublicClientApplication pca;

  Future<void> _acquireToken() async {
    if (pca == null) {
      pca = await PublicClientApplication.createPublicClientApplication(
          "877c0662-a3da-40a3-ac5b-c72dee4b7b49",
          "msauth://uk.co.moodio.msalFlutterV2/Q%2F0D7Tf8HlHBVBk3J0cSapmcwTA%3D",
          authority: [
            Authority(
                type: AuthorityType.AAD,
                audience: Audience(MicrosoftAccount.PersonalMicrosoftAccount,
                    tenantID: "consumers"))
          ]);
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
          "msauth://uk.co.moodio.msalFlutterV2/Q%2F0D7Tf8HlHBVBk3J0cSapmcwTA%3D",
          authority: [
            Authority(
                type: AuthorityType.AAD,
                audience: Audience(MicrosoftAccount.PersonalMicrosoftAccount,
                    tenantID: "consumers"))
          ]);
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
          "msauth://uk.co.moodio.msalFlutterV2/Q%2F0D7Tf8HlHBVBk3J0cSapmcwTA%3D",
          authority: [
            Authority(
                type: AuthorityType.AAD,
                audience: Audience(MicrosoftAccount.PersonalMicrosoftAccount,
                    tenantID: "consumers"))
          ]);
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
