import Flutter
import UIKit
import MSAL

public class SwiftMsalFlutterPlugin: NSObject, FlutterPlugin {
  
  //static fields as initialization isn't really required
  static var clientId : String = ""
  static var authority : String = ""
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "msal_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftMsalFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) 
  {
    //get the arguments as a dictionary
    let dict = call.arguments! as! NSDictionary
    let scopes = dict["scopes"] as? [String] ?? [String]()
    let clientId = dict["clientId"] as? String ?? ""
    let authority = dict["authority"] as? String ?? ""

    switch( call.method ){
      case "initialize": initialize(clientId: clientId, authority: authority, result: result)
      case "acquireToken": acquireToken(scopes: scopes, result: result)
      case "acquireTokenSilent": acquireTokenSilent(scopes: scopes, result: result)
      case "logout": logout(result: result)
      default: result(FlutterError(code:"INVALID_METHOD", message: "The method called is invalid", details: nil))
    } 
  }


  private func acquireToken(scopes: [String], result: @escaping FlutterResult)
  {
    if let application = getApplication(result: result){
          //delete old accounts
      do {
        let cachedAccounts = try application.allAccounts()
        if !cachedAccounts.isEmpty {
          try application.remove(cachedAccounts.first!)
        }
      } catch {
        //nothing to do really
      }
      let viewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
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
      return
    }
  }

  private func acquireTokenSilent(scopes: [String], result: @escaping FlutterResult)
  {
    if let application = getApplication(result: result){
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
      return
    }
  }

  private func getApplication(result: @escaping FlutterResult) -> MSALPublicClientApplication?
  {
    if(SwiftMsalFlutterPlugin.clientId.isEmpty){
      result(FlutterError(code: "NO_CLIENT", message: "Client must be initialized before attempting to acquire a token.", details: nil))
      return nil
    }

    var config: MSALPublicClientApplicationConfig

    //setup the config, using authority if it is set, or defaulting to msal's own implementation if it's not
    if !SwiftMsalFlutterPlugin.authority.isEmpty
    {     
      //try creating the msal aad authority object
      do{
        //create authority url
        guard let authorityUrl = URL(string: SwiftMsalFlutterPlugin.authority) else{
          result(FlutterError(code: "INVALID_AUTHORITY", message: "invalid authority", details: nil))
          return nil
        }

        //create the msal authority and configuration
        let msalAuthority = try MSALAuthority(url: authorityUrl)
        config = MSALPublicClientApplicationConfig(clientId: SwiftMsalFlutterPlugin.clientId, redirectUri: nil, authority: msalAuthority)
      } catch {
        //return error if exception occurs
        result(FlutterError(code: "INVALID_AUTHORITY", message: "invalid authority", details: nil))
        return nil
      }
    }
    else
    {
      config = MSALPublicClientApplicationConfig(clientId: SwiftMsalFlutterPlugin.clientId)
    }

    //create the application and return it
    if let application = try? MSALPublicClientApplication(configuration: config)
    {
      application.validateAuthority = false
      return application
    }else{
      result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication", details: nil))
      return nil
    }
  }

  private func initialize(clientId: String, authority: String, result: @escaping FlutterResult)
  {
    //validate clientid exists
    if(clientId.isEmpty){
      result(FlutterError(code:"NO_CLIENTID", message: "Call must include a clientId", details: nil))
      return
    }

    SwiftMsalFlutterPlugin.clientId = clientId;
    SwiftMsalFlutterPlugin.authority = authority;
    result(true)
  }

  private func logout(result: @escaping FlutterResult)
  {
    if let application = getApplication(result: result){
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
        return
      }
      result(true)
      return
    }
    else {
      return
    }
  }
}
