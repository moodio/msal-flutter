## UPDATES IN PROGRESS
Please note updates are currently in progress. We are not currently accepting any PRs.

# VERSION 1.0.0+ WARNING
Version 1.0.0 uses the updated MSAL Libraries and moves to Android-X. 1.0.0 IS NOT compatiable with older versions. Please only update to 1.0.+ if you are ready to migrate your android app and change how you call the constructor.
Version 1+ is however required to use MSAL on iOS 13+

It is also not recommended to use the login.microsoftonline.com authority and endpoints, as old appear to be being deprecated and do not seperate saved passwords due to domain being the same for all tenants. 
The new authority template is `https://<tenant>.b2clogin.com/tfp/<tenant>.onmicrosoft.com/<user-flow>`
e.g. `https://msalfluttertest.b2clogin.com/tfp/msalfluttertest.onmicrosoft.com/B2C_1_sisu`

For troubleshooting known bugs in the new build, please scroll down to the bottom of the page where all bugs and fixes we find will be noted.

## MSAL Wrapper Library for Flutter
Please note this product is in very early alpha release and subject to change and bugs.

The Microsoft Authentication Library Flutter Wrapper is a wrapper that uses that MSAL libraries for Android and IOS. Currently only the public client application functionality is supported, using the implicit workflow. 
If you have a requirement for additional functionality however please let me know.

## Setup

To use MSAL Flutter in your library, first setup an Azure AD B2C tenant and mobile client if you have not done so already, for which detailed instructions can be found at [https://docs.microsoft.com/en-us/azure/active-directory-b2c/](https://docs.microsoft.com/en-us/azure/active-directory-b2c/) 

### Flutter

Import the [Msal Flutter package](https://pub.dev/packages/msal_flutter/) into your flutter application by adding it to the list of dependencies in your pubsec.yaml file.

```
dependencies:
    msal_flutter: ^1.0.0+2
```
### Android (Kotlin)

NOTE: Due to a [known kotlin issue kotlin](https://youtrack.jetbrains.com/issue/KT-21862) please ensure you are using Kotlin version 1.3.50 or later. To set this, goto your app's android folder, open the build.gradle file, and under buildscript:ext.kotlin_version change the version to 1.3.50 or later.

This section is mostly copied and modified from [the official android MSAL library github repository](https://github.com/AzureAD/microsoft-authentication-library-for-android). Visit the repository for more details and information on how to use it with authentication brokers.

1. Give youyr app internet permissions

```
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

```

2. In your AndroidManifest.xml file add the following intent filter, replacing the placeholder \<YOUR-CLIENT-ID\> for your azure b2c application's client id where indicated below. 
The default redirect url is msal\<YOUR-CLIENT-ID\>://auth however this can now be changed for android. If you have changed your redirect url to something else, please set the below activity settings to match your own.

```
<activity
    android:name="com.microsoft.identity.client.BrowserTabActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="msal<YOUR-CLIENT-ID>"
            android:host="auth" />
    </intent-filter>
</activity>

```

3. Copy the [msal_default_config](https://raw.githubusercontent.com/moodio/msal-flutter/master/doc/templates/msal_default_config.json) from this repository (or make your own if you know what you're doing) and place it into your flutter apps android/src/main/res/raw folder.
By default/tradition the redirect URL is msal\<YOUR-CLIENT-ID\>://auth for android, however if you have selected a different redirect url please enter that. Note the redirect URL scheme and host combination MUST BE UNIQUE to your application and if you do change it it must also be changed in the activity intent filter in step 2.

*WARNING* DO NOT set the application type to single. the MSAL Flutter wrapper is only compatiable with the newer multiple account configuration.

For an example see the example apps usage [here](https://github.com/moodio/msal-flutter/blob/develop/example/android/app/src/main/res/raw/msal_default_config.json)

4. The minimum SDK version must be atleast 21. If you are starting from a new flutter app with the default 16 version, please change this in your gradle settings which can be found in `android > app > build.gradle` file, and then under the object android:defaultConfig>minSdkVersion

### iOS (Swift)
This section is mostly copied and modified from Step 1 from [the official iOS MSAL library github repository](https://github.com/AzureAD/microsoft-authentication-library-for-objc). Visit the repository for more details.


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

2. Add LSApplicationQueriesSchemes to allow making call to Microsoft Authenticator if installed (For Authentication broker)

```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>msauthv2</string>
	<string>msauthv3</string>
</array>

```

3. Open the app's iOS project in xcode, click on the Runner app to open up the configuration, and under capabilities, expand Keychain Sharing and add the keychain group `com.microsoft.adalcache`

4. Import the MSAL library in your AppDelegate.swift by adding the following at the top of the file

`import MSAL`

5. Add the following function to your AppDelegate class

```
override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {    
guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String else {
    return false
}  
return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication)
}
```

6. Trouble shooting
It is possible that you may get errors such as with the minimum iOS deployment being too low. MSAL Flutter requires a minimum iOS version of 11.0
To set this, add `platform :ios, '11.0'` on the first line of your Podfile file which can be found in the root of your ios folder.

When upgrading from older versions of MSAL Flutter, you might also need to delete your Podfile.lock file, which is also in the iOS folder.

## How To Use

1. In flutter, import the package
`import 'package:msal_flutter/msal_flutter.dart';`


2. Use the static factory method createPublicClientApplication to asyncronously create a new instance of the object, by providing your client id, and optionally the authority to authenticate again. 

   With default authority:

   `var pca = await PublicClientApplication.createPublicClientApplication("YOUR-CLIENT-ID");`

   Specifying authroity:

   `var pca = await PublicClientApplication.createPublicClientApplication("YOUR-CLIENT-ID", authority: "https://<tenant>.b2clogin.com/tfp/<tenant>.onmicrosoft.com/<user-flow>");`

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

5. To logout, call the logout method

```
try{
    await pca.logout();
} on MsalException{
    // error handling logic here
}
```

### List of exceptions that can be thrown

| Exception | Description |
| --------- | ----------- |
| MsalException | Base exception, inhertied by all other exceptions. Used for general or unknwon errors |
| MsalChangedClientIdException | Attempt to initialize a second client id with a different clientid |
| MsalInitializationException | Error initializing client. Most likely do to incorrect configuration files |
| MsalInvalidConfigurationException | Configuration error in setting up Public Client Application, such as invalid clientid or authority|
| MsalInvalidScopeException | Invalid scope or no scope supplied. Currently only supported in android |
| MsalNoAccountException | User has not previously logged, has logged out or refresh token has expired and and acquire token silently cannot be performed |
| MsalUninitializedException | Client method called before client has been initialized |
| MsalUserCancelledException | Login request cancelled by user. Only currently supported in Android, for iOS a MsalException is thrown instead|


# Trouble Shooting

Please note there is currently an issue that seems to occur with Android which uses slightly older
 versions of kotlin.
If you get the error when attemtping to acquire a token, along the lines of "static member msalApp 
not found", goto your app's android folder, open the build.gradle file, and on the second line 
change the version of kotlin from 1.3.10 to 1.3.50. For more information take a look at issue #4.
A fix will be implemented shortly.