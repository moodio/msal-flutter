import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msal_flutter/msal_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('msal_flutter');
  PublicClientApplication pca;

  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall call) async {

      if( "initialize" == call.method){
        return "Created successfully";
      }

    });
  });



  test("return Exception when Client Id not set" , () async {


    await PublicClientApplication.createPublicClientApplication(
        null, "msauth://uk.co.moodio.msalFlutterV2/Q%2F0D7Tf8HlHBVBk3J0cSapmcwTA%3D").catchError(expectAsync((e) {
      expect(e, isInstanceOf<MsalInvalidConfigurationException>(),
      );
    }));

  });


  test("return Exception when RedirectUri  not set" , () async {

    await PublicClientApplication.createPublicClientApplication(
        "877c0662-a3da-40a3-ac5b-c72dee4b7b49", null).catchError(expectAsync((e) {
      expect(e, isInstanceOf<MsalInvalidConfigurationException>(),
      );
    }));

  });


  test("return Exception when RedirectUri is Empty" , () async {

    await PublicClientApplication.createPublicClientApplication(
        "877c0662-a3da-40a3-ac5b-c72dee4b7b49", "   ").catchError(expectAsync((e) {
      expect(e, isInstanceOf<MsalInvalidConfigurationException>(),
      );
    }));

  });


  test("return Exception when Client is Empty" , () async {

    await PublicClientApplication.createPublicClientApplication(
        "  ", "msauth://uk.co.moodio.msalFlutterV2/Q%2F0D7Tf8HlHBVBk3J0cSapmcwTA%3D").catchError(expectAsync((e) {
      expect(e, isInstanceOf<MsalInvalidConfigurationException>(),
      );
    }));

  });



}
