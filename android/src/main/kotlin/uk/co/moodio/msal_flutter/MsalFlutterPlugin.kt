package uk.co.moodio.msal_flutter

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalException

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception

@Suppress("SpellCheckingInspection")
class MsalFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    
    private lateinit var activity : Activity
    private lateinit var channel : MethodChannel
    private lateinit var context : Context
    private lateinit var msalApp: IMultipleAccountPublicClientApplication
    private fun isClientInitialized() = ::msalApp.isInitialized

    private fun getAuthCallback(result: Result) : AuthenticationCallback
    {
        Log.d("MsalFlutter", "Getting the auth callback object")
        return object : AuthenticationCallback
        {
            override fun onSuccess(authenticationResult: IAuthenticationResult){
                Log.d("MsalFlutter", "Authentication successful")
                Log.d("MsalFlutter", authenticationResult.accessToken)
                Log.d("MsalFlutter", authenticationResult.toString())

                Handler(Looper.getMainLooper()).post {
                    result.success(authenticationResult.accessToken)
                }
            }

            override fun onError(exception: MsalException)
            {
                Log.d("MsalFlutter", "Error logging in!")
                Log.d("MsalFlutter", exception.errorCode)
                Log.d("MsalFlutter",exception.message ?: "No exception message")
                Log.d("MsalFlutter", exception.stackTraceToString())

                handleMsalException(exception, result)

            }

            override fun onCancel(){
                Log.d("MsalFlutter", "Cancelled")
                Handler(Looper.getMainLooper()).post {
                    result.error("CANCELLED", "User cancelled", "User cancelled")
                }
            }
        }
    }
    
    private fun getApplicationCreatedListener(result: Result) : IPublicClientApplication.ApplicationCreatedListener {
        Log.d("MsalFlutter", "Getting the created listener")
        return object : IPublicClientApplication.ApplicationCreatedListener
        {
            override fun onCreated(application: IPublicClientApplication) {
                msalApp = application as MultipleAccountPublicClientApplication
                Handler(Looper.getMainLooper()).post {
                    result.success(true)
                }
            }

            override fun onError(exception: MsalException?) {
                Log.d("MsalFlutter", "Initialize error")
                if(exception != null){
                    handleMsalException(exception, result)
                }else {
                    Log.d("MsalFlutter","Error thrown without exception")
                    Handler(Looper.getMainLooper()).post {
                        result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
                    }
                }
            }
        }
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        Log.d("MsalFlutter","Detached from activity")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d("MsalFlutter","Detached from activity for config")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding){
        activity = binding.activity
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("MsalFlutter", "MSAL attached")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "msal_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext;
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
           "logout" -> Thread(Runnable { logout(result) }).start()
           "initialize" -> initialize(clientId, authority, redirectUri, result)
           "acquireToken" -> Thread(Runnable { acquireToken(scopes, result) }).start()
           "acquireTokenSilent" -> Thread(Runnable { acquireTokenSilent(scopes, result) }).start()
           else -> result.notImplemented()
       }

    }

    private fun acquireToken(scopes: Array<String>?, result: Result)
    {
        Log.d("MsalFlutter", "acquire token called")

        //logout of old accounts
        clearAccounts()

        // check if client has been initialized
        if(!isClientInitialized()){
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
            }
        }

        //check scopes
        if(scopes == null) {
            Log.d("MsalFlutter", "no scope")
            result.error("NO_SCOPE", "Call must include a scope", null)
            return
        }

        //acquire the token
        try {
            msalApp.acquireToken(activity, scopes, getAuthCallback(result))
        }catch(e: MsalException){
            handleMsalException(e, result)
        }catch(e: Throwable){
            Log.d("MsalFlutter", "Throwable thrown");
            Handler(Looper.getMainLooper()).post {
                result.error("UNKNOWN", "An unknown error occured.", e.localizedMessage)
            }
        }
    }

    private fun acquireTokenSilent(scopes: Array<String>?, result: Result)
    {
        Log.d("MsalFlutter", "Called acquire token silent")

        // check if client has been initialized
        if(!isClientInitialized()){
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
            }
        }

        //check the scopes
        if(scopes == null){
            Log.d("MsalFlutter", "no scope")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_SCOPE", "Call must include a scope", null)
            }
            return
        }

        //ensure accounts exist
        val accounts = msalApp.accounts
        if(accounts.isEmpty()){
            Handler(Looper.getMainLooper()).post {
                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", null)
            }
            return
        }

        //acquire the token and return the result
        try {
            val res = msalApp.acquireTokenSilent(scopes, accounts[0], msalApp.configuration.defaultAuthority.authorityURL.toString())
            Handler(Looper.getMainLooper()).post {
                result.success(res.accessToken)
            }
        } catch(e: MsalException){
            handleMsalException(e, result)
        }catch(e: Throwable){
            Log.d("MsalFlutter", "Throwable thrown");
            Handler(Looper.getMainLooper()).post {
                result.error("UNKNOWN", "An unknown error occured.", e.localizedMessage)
            }
        }
    }

    private fun clearAccounts(){
        while(msalApp.accounts.any()){
            msalApp.removeAccount(msalApp.accounts.first())
        }
    }

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
           if(msalApp.configuration.clientId == clientId)
           {
               result.success(true)
           } else {
               result.error("CHANGED_CLIENTID", "Attempting to initialize with multiple clientIds.", null)
           }
       }


       try {
           PublicClientApplication.create(context, clientId, authority, redirectUri
                   ?: getRedirectUri(), getApplicationCreatedListener(result))
       } catch (e: Throwable){
           Log.d("MsalFlutter", "Exception thrown");
           Handler(Looper.getMainLooper()).post {
               result.error("UNKNOWN", "Unknown error occurred.", e.localizedMessage)
           }
       }
   }

    private fun getRedirectUri() : String{
        return "msauth://${context.packageName}/auth"
        //TODO: Add base64 encoded signature
    }

    private fun logout(result: Result){
        clearAccounts()
        Handler(Looper.getMainLooper()).post {
            result.success(true)
        }
    }

    // converts an azure ad error code to a msal flutter one, and returns error
    private fun handleMsalException(exception: MsalException, result: Result){

        val errorCode : String = when(exception.errorCode){
            "access_denied" -> "CANCELLED"
            "declined_scope_error" -> "SCOPE_ERROR"
            "invalid_request" -> "INVALID_REQUEST"
            "unknown_authority" -> "INVALID_AUTHORITY"
            "unknown_error" -> "UNKNOWN"
            else -> "AUTH_ERROR"
        }

        //return result
        Handler(Looper.getMainLooper()).post {
            result.error(errorCode, "Authentication failed", exception.localizedMessage)
        }
    }
}
