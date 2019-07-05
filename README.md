# MSAL Wrapper Library for Flutter
Please note this product is in very early alpha release and subject to change and bugs.

The Microsoft Authentication Library Flutter Wrapper is a wrapper that uses that MSAL libraries for Android and IOS. Currently only the public client application functionality is supported, using the implicit workflow. 
If you have a requirement for additional functionality however please let me know.

## Setup

To use MSAL Flutter in your library, first setup an Azure AD B2C tenant and mobile client if you have not done so already, for which detailed instructions can be found at [https://docs.microsoft.com/en-us/azure/active-directory-b2c/](https://docs.microsoft.com/en-us/azure/active-directory-b2c/) 

### Flutter

Import the Msal Flutter package into your flutter application by adding it to the list of dependencies in your pubsec.yaml file.

### Android

In your AndroidManifest.xml file add the following intent filter, replacing the placeholder for your azure b2c application's client id where indicated below.

```<activity
        android:name="com.microsoft.identity.client.BrowserTabActivity">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="msal[YOUR-CLIENT-ID]"
                android:host="auth" />
        </intent-filter>
    </activity>```

In your MainActivity.kt add the following function

1. Import the following libraries

```import uk.co.moodio.msal_flutter.MsalFlutterPlugin
import android.content.Intent
```

2. Add the following function within the MainActivity class
```
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
      super.onActivityResult(requestCode, resultCode, data)
      Log.d("MsalAuth","Activity resulted")
      MsalFlutterPlugin.handleInteractiveRequestRedirect(requestCode, resultCode, data)
  }
  ```

### iOS


## How To Use
