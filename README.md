# MSAL Wrapper Library for Flutter
The Microsoft Authentication Library Flutter Wrapper is a wrapper that uses that MSAL libraries for Android and IOS. Currently only the public client application functionality is supported, using the implicit workflow. 
However more functionality may be added if there is a need for it.

## Setup

### Flutter

### Android

In your AndroidManifest.xml file add:

```<activity
        android:name="com.microsoft.identity.client.BrowserTabActivity">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="@string/msal_scheme"
                android:host="auth" />
        </intent-filter>
    </activity>```

in your res\values\strings.xml (create the file if you do not currently have one), add the following under the <resources> object
```<string name="msal_scheme">msal[YOUR-MSAL-CLIENT-ID]</string>```


In your MainActivity.kt

1. Import the following

```import uk.co.moodio.msal_flutter.MsalFlutterPlugin
import android.content.Intent
```

2. Add the following method
```
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
      super.onActivityResult(requestCode, resultCode, data)
      Log.d("MsalAuth","Activity resulted")
      MsalFlutterPlugin.handleInteractiveRequestRedirect(requestCode, resultCode, data)
  }
  ```
### iOS


## How To Use
