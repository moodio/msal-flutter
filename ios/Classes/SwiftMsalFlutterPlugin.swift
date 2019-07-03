import Flutter
import UIKit
import MSAL

public class SwiftMsalFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "msal_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftMsalFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) 
  {
    //get the arguments as a dictionary
    let dict = call.arguments! as! NSDictionary
    let scopes = dict["scopes"] as! [String]
    let clientId = dict["clientId"] as! String
    
    var config: MSALPublicClientApplicationConfig

    //setup the config, using authority if it is set, or defaulting to msal's own implementation if it's not
    if let authorityArg = dict["authority"] as? String 
    {     
      //ensure authroity url is valid
      guard let authorityUrl = URL(string: authorityArg) else{
        result.error("invalid authority")
        return
      }

      //try creating the msal aad authority object
      do{
        let authority = try MSALAuthority(url: authorityUrl)
        config = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: nil, authority: authority)
      } catch let error as NSError {
        result.error("error with authority: \(error)")
        return
      }
      
    }
    else
    {
      config = MSALPublicClientApplicationConfig(clientId: clientId)
    }

    if let application = try? MSALPublicClientApplication(configuration: config) {
            
           let interactiveParameters = MSALInteractiveTokenParameters(scopes: scopes)
            application.acquireToken(with: interactiveParameters, completionBlock: { (msalresult, error) in
                
                guard let authResult = msalresult, error == nil else {
                    result.error("unable to authenticate \(error)")
                    return
                }
                
                // Get access token from result
                let accessToken = authResult.accessToken

                result(accessToken)
            })
        }
        else {
            result.error("unable to authenticate")
        }

    // switch( call.method ){
    //   case "acquireToken": result("hi \(scopes)")
    //   case "acquireTokenSilent": result("hello")
    //   default: result("the fuck was that?")
    // }
  }

}
