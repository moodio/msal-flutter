# MSAL Wrapper Library for Flutter
Please note this product is in very early alpha release and subject to change and bugs.

The Microsoft Authentication Library Flutter Wrapper is a wrapper that uses that MSAL libraries for Android and IOS. Currently only the public client application functionality is supported, using the implicit workflow. 
If you have a requirement for additional functionality however please let me know.

## Setup

To use MSAL Flutter in your library, first setup an Azure AD B2C tenant and mobile client if you have not done so already, for which detailed instructions can be found at [https://docs.microsoft.com/en-us/azure/active-directory-b2c/](https://docs.microsoft.com/en-us/azure/active-directory-b2c/) 

### Flutter

Import the [Msal Flutter package](https://pub.dev/packages/msal_flutter/) into your flutter application by adding it to the list of dependencies in your pubsec.yaml file.

```
dependencies:
    msal_flutter: ^0.1.2
```
### Android (Kotlin)

This section is mostly copied and modified from [the official android MSAL library github repository](https://github.com/AzureAD/microsoft-authentication-library-for-android). Visit the repository for more details.

1. Give youyr app internet permissions

```
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

2. In your AndroidManifest.xml file add the following intent filter, replacing the placeholder for your azure b2c application's client id where indicated below.

```
<activity
    android:name="com.microsoft.identity.client.BrowserTabActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="msal[YOUR-CLIENT-ID]"
            android:host="auth" />
    </intent-filter>
</activity>
```

3. In your MainActivity.kt import the following libraries

```
import uk.co.moodio.msal_flutter.MsalFlutterPlugin
import android.content.Intent
```

4. In your MainActivity.kt file add the following function within the MainActivity class
```
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
      super.onActivityResult(requestCode, resultCode, data)
      Log.d("MsalAuth","Activity resulted")
      MsalFlutterPlugin.handleInteractiveRequestRedirect(requestCode, resultCode, data)
  }
  ```

### iOS (Swift)
This section is mostly copied and modified from Step 1 from [the official android MSAL library github repository](https://github.com/AzureAD/microsoft-authentication-library-for-objc). Visit the repository for more details.


1. Add your URL scheme for callbacks to your Info.plist file, replacing the placeholder for your azure b2c application's client id where indicated below.

```
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>msauth.[BUNDLE-ID]</string>
        </array>
    </dict>
</array>
```

2. Open the app's iOS project in xcode, click on the Runner app to open up the configuration, and under capabilities, expand Keychain Sharing and add the keychain group `com.microsoft.adalcache`

3. Import the MSAL library in your AppDelegate.swift by adding the following at the top of the file

`import MSAL`

4. Add the following function to your AppDelegate class

```
override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {    
guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String else {
    return false
}  
return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication)
}
```

## How To Use

1. In flutter, import the package
`import 'package:msal_flutter/msal_flutter.dart';`


2. create a new instance of the object, providing your client id, and optionally the authority to authenticate again. 

   With default authority:

   `PublicClientApplication("YOUR-CLIENT-ID");`

   Specifying authroity:

   `PublicClientApplication("YOUR-CLIENT-ID", authority: "https://login.microsoftonline.com/tfp/[[YOUR-TENANT]/[YOUR-FLOW]");`

   If this is null the default authority will be used, as defined by the relevant MSAL library implementation, which currently is the common endpoint.

3. To retrieve a token interactivity, call the acquireToken function passing the scopes you wish to acquire the token for. Note that this function will throw an error on failure and should be surrounded by a try catch block as per the example below

   **DO NOT** include the openid or user_impersonation scopes which are added by default

 ```
try{
    String token = await pca.acquireToken(["https://msalfluttertest.onmicrosoft.com/msalbackend/user_impersonation"]);
} on MsalException {
    //error handling logic here
}
```

4. Once a user has logged in atleast once, to retrieve a token silently call the acquireTokenSilent function, passing the scopes you wish to acquire the token for. Note that this function will throw an error on failure and should be surrounded by a try catch block as per the example below

   **DO NOT** include the openid or user_impersonation scopes which are added by default


```
try{
    String token = await pca.acquireTokenSilent(["https://msalfluttertest.onmicrosoft.com/msalbackend/user_impersonation"]);
} on MsalException{
    // error handling logic here
}
```

### List of exceptions that can be thrown

| Exception | Description |
| --------- | ----------- |
| MsalException | Base exception, inhertied by all other exceptions. Used for general or unknwon errors |
| MsalInvalidConfigurationException | Configuration error in setting up Public Client Application, such as invalid clientid or authority|
| MsalInvalidScopeException | Invalid scope or no scope supplied. Currently only supported in android |
| MsalNoAccountException | User has not previously logged, has logged out or refresh token has expired and and acquire token silently cannot be performed |
| MsalUserCancelledException | Login request cancelled by user. Only currently supported in Android, for iOS a MsalException is thrown instead|