import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:msal_flutter/msal_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = 'NONE';

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     platformVersion = await MsalFlutter.acquireToken(["https://graph.microsoft.com/User.Read"]);
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  Future<void> _acquireToken() async{
    String res;
    try{
      res = await PublicClientApplication.acquireToken(["https://graph.microsoft.com/User.Read"]);
    } on PlatformException {
      res = "Error getting token";
    }

    setState(() {
      _output = res;
    });
  }

  Future<void> _acquireTokenSilently() async {
    String res;
    try
    {
      res = await PublicClientApplication.acquireTokenSilent(["https://graph.microsoft.com/User.Read"]);
    } on PlatformException{
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
