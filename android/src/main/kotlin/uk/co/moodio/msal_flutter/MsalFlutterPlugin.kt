package uk.co.moodio.msal_flutter

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.WorkerThread
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.IPublicClientApplication
import com.microsoft.identity.client.PublicClientApplicationConfigurationFactory.initializeConfiguration


@Suppress("SpellCheckingInspection")
class MsalFlutterPlugin: MethodCallHandler {
    companion object
    {
        lateinit var mainActivity : Activity
        lateinit var msalApp: IMultipleAccountPublicClientApplication

        fun isClientInitialized() = ::msalApp.isInitialized

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            Log.d("MsalFlutter","Registering plugin")
            val channel = MethodChannel(registrar.messenger(), "msal_flutter")
            channel.setMethodCallHandler(MsalFlutterPlugin())
            mainActivity = registrar.activity()
        }

        fun getAuthCallback(result: Result) : AuthenticationCallback
        {
            Log.d("MsalFlutter", "Getting the auth callback object")
            return object : AuthenticationCallback
            {
                override fun onSuccess(authenticationResult : IAuthenticationResult){
                    Log.d("MsalFlutter", "Authentication successful")
                    Handler(Looper.getMainLooper()).post {
                        result.success(authenticationResult.accessToken)
                    }
                }

                override fun onError(exception : MsalException)
                {
                    Log.d("MsalFlutter","Error logging in!")
                    Log.d("MsalFlutter", exception.message)
                    Handler(Looper.getMainLooper()).post {
                        result.error("AUTH_ERROR", "Authentication failed", exception.localizedMessage)
                    }
                }

                override fun onCancel(){
                    Log.d("MsalFlutter", "Cancelled")
                    Handler(Looper.getMainLooper()).post {
                        result.error("CANCELLED", "User cancelled", null)
                    }
                }
            }
        }

        private fun getApplicationCreatedListener(result: Result) : IPublicClientApplication.ApplicationCreatedListener {
            Log.d("MsalFlutter", "Getting the created listener")

            return object : IPublicClientApplication.ApplicationCreatedListener
            {
                override fun onCreated(application: IPublicClientApplication) {
                    Log.d("MsalFlutter", "Created successfully")
                    msalApp = application as MultipleAccountPublicClientApplication
                    result.success(true)
                }

                override fun onError(exception: MsalException?) {
                    Log.d("MsalFlutter", "Initialize error")
                    result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result)
    {
        val scopesArg : ArrayList<String>? = call.argument("scopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
        val clientId : String? = call.argument("clientId")
        val authority : String? = call.argument("authority")

        Log.d("MsalFlutter","Got scopes: $scopes")
        Log.d("MsalFlutter","Got cleintId: $clientId")
        Log.d("MsalFlutter","Got authority: $authority")

        when(call.method){
            "logout" -> Thread(Runnable{logout(result)}).start()
            "initialize" -> initialize(clientId, authority, result)
            "acquireToken" -> Thread(Runnable {acquireToken(scopes, result)}).start()
            "acquireTokenSilent" -> Thread(Runnable {acquireTokenSilent(scopes, result)}).start()
            else -> result.notImplemented()
        }

    }

    private fun acquireToken(scopes : Array<String>?, result: Result)
    {
        Log.d("MsalFlutter", "acquire token called")
        if(scopes == null){
            Log.d("MsalFlutter", "no scope")
            result.error("NO_SCOPE", "Call must include a scope", null)
            return
        }

        while(msalApp.accounts.any()){
            Log.d("MsalFlutter","Removing old account")
            msalApp.removeAccount(msalApp.accounts.first())
        }

        msalApp.acquireToken(mainActivity, scopes, getAuthCallback(result))
    }

    private fun acquireTokenSilent(scopes : Array<String>?, result: Result)
    {
        Log.d("MsalFlutter", "Called acquire token silent")
        if(scopes == null){
            Log.d("MsalFlutter", "no scope")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_SCOPE", "Call must include a scope", null)
            }
            return
        }

        Log.d("MsalFlutter", "Scopes exist")

        val size = msalApp.accounts.size
        Log.d("MsalFlutter", "Accounts $size")

        if(msalApp.accounts.isEmpty()){
            Handler(Looper.getMainLooper()).post {
                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", null)
            }
            return
        }

        Log.d("MsalFlutter", "calling acquireTokenSilent")
        val res = msalApp.acquireTokenSilent(scopes, msalApp.accounts[0], msalApp.configuration.defaultAuthority.authorityURL.toString())

        Log.d("MsalFlutter","Token acquired")
        Handler(Looper.getMainLooper()).post {
            result.success(res.accessToken)
        }
    }

    private fun initialize(clientId: String?, authority: String?, result: Result)
    {
        if(clientId == null){
            Log.d("MsalFlutter","error no clientId")
            result.error("NO_CLIENTID", "Call must include a clientId", null)
            return
        }

        if(isClientInitialized()){
            Log.d("MsalFlutter","Client already initialized.")
            if(msalApp.configuration.clientId == clientId)
            {
                result.success(true)
            } else {
                result.error("CHANGED_CLIENTID", "Attempting to initialize with multiple clientIds.", null)
            }
        }

        Log.d("MsalFlutter","Not initialized. Initializing client")
        if(authority != null){
            Log.d("MsalFlutter", "Authority not null")
            Log.d("MsalFlutter", "Creating with: $clientId - $authority")
            PublicClientApplication.create(mainActivity.applicationContext, clientId, authority, getApplicationCreatedListener(result))
        }else{
            Log.d("MsalFlutter", "Authority null")
            PublicClientApplication.create(mainActivity.applicationContext, clientId, getApplicationCreatedListener(result))
        }
    }


    private fun logout(result: Result){
        while(msalApp.accounts.any()){
            Log.d("MsalFlutter","Removing old account")
            msalApp.removeAccount(msalApp.accounts.first())
        }
        Handler(Looper.getMainLooper()).post {
            result.success(true)
        }
    }
}
