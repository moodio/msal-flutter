import UIKit
import Flutter
// -- import this
import MSAL
// --
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // -- add this function
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
    guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String else {
        return false
    }  
    return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication)
  }
    // -- 
}
