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
        result(FlutterError(code: "INVALID_AUTHORITY", message: "invalid authority", details: nil))
        return
      }

      //try creating the msal aad authority object
      do{
        let authority = try MSALAuthority(url: authorityUrl)
        config = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: nil, authority: authority)
      } catch {
        result(FlutterError(code: "INVALID_AUTHORITY", message: "invalid authority", details: nil))
        return
      }
      
    }
    else
    {
      config = MSALPublicClientApplicationConfig(clientId: clientId)
    }


    switch( call.method ){
      case "acquireToken": acquireToken(configuration: config, scopes: scopes, result: result)
      case "acquireTokenSilent": acquireTokenSilent(configuration: config, scopes: scopes, result: result)
      case "logout": logout(configuration: config, result: result)
      default: result(FlutterError(code:"INVALID_METHOD", message: "The method called is invalid", details: nil))
    }
    
  }


  private func acquireToken(configuration: MSALPublicClientApplicationConfig, scopes: [String], result: @escaping FlutterResult)
  {
    if let application = try? MSALPublicClientApplication(configuration: configuration) {
            
          application.validateAuthority = false;
          //delete old accounts
          do {
            let cachedAccounts = try application.allAccounts()
            if !cachedAccounts.isEmpty {
              try application.remove(cachedAccounts.first!)
            }
          } catch {
            //nothing to do really
          }
          let viewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController as! UIViewController
          let webViewParameters = MSALWebviewParameters(parentViewController: viewController)
          let interactiveParameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webViewParameters)
            application.acquireToken(with: interactiveParameters, completionBlock: { (msalresult, error) in
                
                guard let authResult = msalresult, error == nil else {
                  result(FlutterError(code: "AUTH_ERROR", message: "Authentication error", details: error!.localizedDescription))
                  return
                }
                
                // Get access token from result
                let accessToken = authResult.accessToken

                result(accessToken)
            })
        }
        else {
            result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication", details: nil))
                    
        }
  }

  private func acquireTokenSilent(configuration: MSALPublicClientApplicationConfig, scopes: [String], result: @escaping FlutterResult)
  {
    if let application = try? MSALPublicClientApplication(configuration: configuration) 
    {
      application.validateAuthority = false;
      var account : MSALAccount!
      
      do{
        let cachedAccounts = try application.allAccounts()
        if cachedAccounts.isEmpty {
          let error = FlutterError(code: "NO_ACCOUNT",  message: "No account is available to acquire token silently for", details: nil)
          result(error)
          return
        }
        //set account as the first account
        account = cachedAccounts.first!
      } 
      catch{
        result(FlutterError(code: "NO_ACCOUNT",  message: "Error retrieving an existing account", details: nil))
      }
        
      let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)

      application.acquireTokenSilent(with: silentParameters, completionBlock: { (msalresult, error) in
                
        guard let authResult = msalresult, error == nil else {
            result(FlutterError(code: "AUTH_ERROR", message: "Authentication error", details: nil))
            return
        }
        
        // Get access token from result
        let accessToken = authResult.accessToken

        result(accessToken)
      })
    }
    else {
      result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication", details: nil))
    }
  }

  private func logout(configuration: MSALPublicClientApplicationConfig, result: @escaping FlutterResult)
  {
    if let application = try? MSALPublicClientApplication(configuration: configuration){
      
      do{
        let cachedAccounts = try application.allAccounts()

        if cachedAccounts.isEmpty {
          result(true)
          return
        }

        let account = cachedAccounts.first!
        try application.remove(account)
      
      } 
      catch {
        result(FlutterError(code: "CONFIG_ERROR", message: "Unable get remove accounts", details: nil))
      }
      result(true)
    }
    else {
      result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication", details: nil))
    }
  }
}
