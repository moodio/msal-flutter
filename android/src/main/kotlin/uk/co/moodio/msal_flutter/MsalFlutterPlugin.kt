package uk.co.moodio.msal_flutter

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Handler
import android.os.Looper
import android.os.Trace
import android.util.Log
import androidx.annotation.NonNull
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

@Suppress("SpellCheckingInspection")
class MsalFlutterPlugin: FlutterPlugin, MethodCallHandler {
    
    private lateinit var channel : MethodChannel
    private lateinit var context : Context
   private lateinit var msalApp: IMultipleAccountPublicClientApplication
   private fun isClientInitialized() = ::msalApp.isInitialized

//    companion object
//    {
//         private lateinit var msalApp: IMultipleAccountPublicClientApplication
//         private fun isClientInitialized() = ::msalApp.isInitialized

//        private fun getApplicationCreatedListener(result: Result) : IPublicClientApplication.ApplicationCreatedListener {
//             Log.d("MsalFlutter", "Getting the created listener")
//             return object : IPublicClientApplication.ApplicationCreatedListener
//             {
//                 override fun onCreated(application: IPublicClientApplication) {
//                     Log.d("MsalFlutter", "Created successfully")
//                     msalApp = application as MultipleAccountPublicClientApplication
//                     result.success(true)
//                 }

//                 override fun onError(exception: MsalException?) {
//                     Log.d("MsalFlutter", "Initialize error")
//                     result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
//                 }
//             }
//         }

    //    fun getAuthCallback(result: Result) : AuthenticationCallback
    //    {
    //        Log.d("MsalFlutter", "Getting the auth callback object")
    //        return object : AuthenticationCallback
    //        {
    //            override fun onSuccess(authenticationResult: IAuthenticationResult){
    //                Log.d("MsalFlutter", "Authentication successful")
    //                Handler(Looper.getMainLooper()).post {
    //                    result.success(authenticationResult.accessToken)
    //                }
    //            }

    //            override fun onError(exception: MsalException)
    //            {
    //                Log.d("MsalFlutter", "Error logging in!")
    //                Log.d("MsalFlutter", exception.message)
    //                Handler(Looper.getMainLooper()).post {
    //                    result.error("AUTH_ERROR", "Authentication failed", exception.localizedMessage)
    //                }
    //            }

    //            override fun onCancel(){
    //                Log.d("MsalFlutter", "Cancelled")
    //                Handler(Looper.getMainLooper()).post {
    //                    result.error("CANCELLED", "User cancelled", null)
    //                }
    //            }
    //        }
    //    }
   // }

   private fun getApplicationCreatedListener(result: Result) : IPublicClientApplication.ApplicationCreatedListener {
        Log.d("MsalFlutter", "Getting the created listener")
        return object : IPublicClientApplication.ApplicationCreatedListener
        {
            override fun onCreated(application: IPublicClientApplication) {
                Log.d("MsalFlutter", "Created successfully")
                // msalApp = application as MultipleAccountPublicClientApplication
                // result.success(true)
            }

            override fun onError(exception: MsalException?) {
                Log.d("MsalFlutter", "Initialize error")
                // result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
            }
        }
    }



   

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("MsalFlutter", "MSAL attached")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "msal_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.getApplicationContext();
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("MsalFlutter", "MSAL detached");
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result)
    {
        val scopesArg : ArrayList<String>? = call.argument("scopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
        val clientId : String? = call.argument("clientId")
        val authority : String? = call.argument("authority")
        val redirectUri : String? = call.argument("redirectUri")

       when(call.method){
        //    "logout" -> Thread(Runnable { logout(result) }).start()
           "initialize" -> initialize(clientId, authority, redirectUri, result)
        //    "acquireToken" -> Thread(Runnable { acquireToken(scopes, result) }).start()
        //    "acquireTokenSilent" -> Thread(Runnable { acquireTokenSilent(scopes, result) }).start()
           else -> result.notImplemented()
            // else -> result.success("nothing");
       }

    }

//    private fun acquireToken(scopes: Array<String>?, result: Result)
//    {
//        Log.d("MsalFlutter", "acquire token called")
//
//        // check if client has been initialized
//        if(!isClientInitialized()){
//            Log.d("MsalFlutter", "Client has not been initialized")
//            Handler(Looper.getMainLooper()).post {
//                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
//            }
//        }
//
//        //check scopes
//        if(scopes == null){
//            Log.d("MsalFlutter", "no scope")
//            result.error("NO_SCOPE", "Call must include a scope", null)
//            return
//        }
//
//        //remove old accounts
//        while(msalApp.accounts.any()){
//            Log.d("MsalFlutter", "Removing old account")
//            msalApp.removeAccount(msalApp.accounts.first())
//        }
//
//        //acquire the token
//        msalApp.acquireToken(mainActivity, scopes, getAuthCallback(result))
//    }
//
//    private fun acquireTokenSilent(scopes: Array<String>?, result: Result)
//    {
//        Log.d("MsalFlutter", "Called acquire token silent")
//
//        // check if client has been initialized
//        if(!isClientInitialized()){
//            Log.d("MsalFlutter", "Client has not been initialized")
//            Handler(Looper.getMainLooper()).post {
//                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
//            }
//        }
//
//        //check the scopes
//        if(scopes == null){
//            Log.d("MsalFlutter", "no scope")
//            Handler(Looper.getMainLooper()).post {
//                result.error("NO_SCOPE", "Call must include a scope", null)
//            }
//            return
//        }
//
//        //ensure accounts exist
//        if(msalApp.accounts.isEmpty()){
//            Handler(Looper.getMainLooper()).post {
//                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", null)
//            }
//            return
//        }
//
//        //acquire the token and return the result
//        val res = msalApp.acquireTokenSilent(scopes, msalApp.accounts[0], msalApp.configuration.defaultAuthority.authorityURL.toString())
//        Handler(Looper.getMainLooper()).post {
//            result.success(res.accessToken)
//        }
//    }

   private fun initialize(clientId: String?, authority: String?, redirectUri: String?, result: Result)
   {
       //ensure clientid provided
       if(clientId == null){
           Log.d("MsalFlutter", "error no clientId")
           result.error("NO_CLIENTID", "Call must include a clientId", null)
           return
       }

       //if already initialized, ensure clientid hasn't changed
       if(isClientInitialized()){
           Log.d("MsalFlutter", "Client already initialized.")
           if(msalApp.configuration.clientId == clientId)
           {
               result.success(true)
           } else {
               result.error("CHANGED_CLIENTID", "Attempting to initialize with multiple clientIds.", null)
           }
       }

       PublicClientApplication.create(context, clientId, authority, redirectUri ?: getRedirectUri(), getApplicationCreatedListener(result))
       Log.d("MsalFlutter", "Client created")
   }

//    private fun getDefaultAuthority() : String{
//
//    }

    private fun getRedirectUri() : String{
        return "msauth://${context.packageName}"
        //TODO: Add base64 encoded signature
    }

//    private fun logout(result: Result){
//        while(msalApp.accounts.any()){
//            Log.d("MsalFlutter", "Removing old account")
//            msalApp.removeAccount(msalApp.accounts.first())
//        }
//        Handler(Looper.getMainLooper()).post {
//            result.success(true)
//        }
//    }
}
