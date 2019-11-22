package uk.co.moodio.msal_flutter_example

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

//-- import the following
import uk.co.moodio.msal_flutter.MsalFlutterPlugin
import android.content.Intent
//---

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }

//add this method
//---
  // override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
  //     super.onActivityResult(requestCode, resultCode, data)
  //     MsalFlutterPlugin.handleInteractiveRequestRedirect(requestCode, resultCode, data)
  // }
    //----
}
