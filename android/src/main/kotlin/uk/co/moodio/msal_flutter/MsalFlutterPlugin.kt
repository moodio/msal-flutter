package uk.co.moodio.msal_flutter

import android.app.Activity
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalException

@Suppress("SpellCheckingInspection")
class MsalFlutterPlugin: MethodCallHandler {
    companion object
    {
        lateinit var mainActivity : Activity
        // lateinit var lastResult : Result
        lateinit var msalApp: PublicClientApplication

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "msal_flutter")
            channel.setMethodCallHandler(MsalFlutterPlugin())
            mainActivity = registrar.activity()
        }

        fun getAuthCallback(result: Result) : AuthenticationCallback
        {
            Log.d("MsalFlutter", "Getting the auth callback object")
            return object : AuthenticationCallback
            {
                @Override
                override fun onSuccess(authenticationResult : AuthenticationResult){
                    Log.d("MsalFlutter", "Authentication successful")
                    result.success(authenticationResult.accessToken)
                }

                @Override
                override fun onError(exception : MsalException)
                {
                    Log.d("MsalFlutter","Error logging in!")
                    Log.d("MsalFlutter", exception.message)
                    result.error("AUTH_ERROR","Authentication failed", null)
                }

                @Override
                override fun onCancel(){
                    Log.d("MsalFlutter", "Cancelled")
                    result.error("CANCELLED","User cancelled", null)
                }
            }
        }

        fun handleInteractiveRequestRedirect(requestCode: Int, resultCode: Int, data: Intent?)
        {
            msalApp?.handleInteractiveRequestRedirect(requestCode, resultCode, data)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result)
    {

        //call signout
        if(call.method == "logout"){
            logout()
            return
        }

        val scopesArg : ArrayList<String>? = call.argument("scopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
        val clientId : String? = call.argument("clientId")
        val authority : String? = call.argument("authority")

        Log.d("MsalFlutter","Got scopes: $scopes")
        Log.d("MsalFlutter","Got cleintId: $clientId")
        Log.d("MsalFlutter","Got authority: $authority")

        if(scopes == null){
            Log.d("MsalFlutter", "no scope")
            result.error("NO_SCOPE","Call must include a scope", null)
            return
        }

        if(clientId == null){
            Log.d("MsalFlutter","error no clientId")
            result.error("NO_CLIENTID", "Call must include a clientId", null)
            return
        }

        msalApp = getPublicClientApplication(clientId, scopes, authority)
        
        when(call.method){
            "acquireToken" -> acquireToken(scopes, result)
            "acquireTokenSilent" -> acquireTokenSilent(scopes, result)
            else -> result.notImplemented()
        }

    }

    private fun acquireToken(scopes : Array<String>, result: Result)
    {
        while(msalApp.accounts.any()){
            Log.d("MsalFlutter","Removing old account")
            msalApp.removeAccount(msalApp.accounts.first())
        }
        Log.d("MsalFlutter", "calling acquireToken")
        msalApp.acquireToken(mainActivity, scopes, MsalFlutterPlugin.getAuthCallback(result))
    }

    private fun acquireTokenSilent(scopes : Array<String>, result: Result)
    {
        val size = msalApp.accounts.size
        Log.d("MsalFlutter", "Accounts $size")

        if(msalApp.accounts.isEmpty()){
            result.error("NO_ACCOUNT","No account is available to acquire token silently for", null)
            return
        }
        Log.d("MsalFlutter", "calling acquireTokenSilent")
        msalApp.acquireTokenSilentAsync(scopes, msalApp.accounts[0], MsalFlutterPlugin.getAuthCallback(result))
    }

    private fun getPublicClientApplication(clientId: String, scopes: Array<String>, authority: String?) : PublicClientApplication
    {
        if(authority!=null){
            return PublicClientApplication(mainActivity.applicationContext, clientId, authority)
        } else{
            return PublicClientApplication(mainActivity.applicationContext, clientId)
        }

    }

    private fun logout(){
        for(account in msalApp.accounts)
        {
            msalApp.removeAccount(account)
        }
    }
}
