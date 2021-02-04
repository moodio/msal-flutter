package uk.co.moodio.msal_flutter

import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.WorkerThread
import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import android.content.Context

import io.flutter.plugin.common.PluginRegistry.Registrar

import com.microsoft.identity.client.AuthenticationCallback

import com.microsoft.identity.client.IAccount

import com.microsoft.identity.client.IAuthenticationResult

import com.microsoft.identity.client.IPublicClientApplication

import com.microsoft.identity.client.IMultipleAccountPublicClientApplication
import com.microsoft.identity.client.ISingleAccountPublicClientApplication

import com.microsoft.identity.client.PublicClientApplication

import com.microsoft.identity.client.SilentAuthenticationCallback

import com.microsoft.identity.client.exception.MsalClientException

import com.microsoft.identity.client.exception.MsalException

import com.microsoft.identity.client.exception.MsalServiceException

import com.microsoft.identity.client.exception.MsalUiRequiredException

import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import com.microsoft.identity.client.SingleAccountPublicClientApplication
import com.microsoft.identity.client.MultipleAccountPublicClientApplication
import com.microsoft.identity.client.IPublicClientApplication.LoadAccountsCallback

@Suppress("SpellCheckingInspection")
class MsalFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private var accountList: List<IAccount>? = null

    companion object {
        private lateinit var activity: Activity
        private lateinit var context: Context
        private lateinit var channel: MethodChannel
        lateinit var msalApp: IMultipleAccountPublicClientApplication

        fun isClientInitialized() = ::msalApp.isInitialized

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            Log.d("MsalFlutter", "Registering plugin")
            val channel = MethodChannel(registrar.messenger(), "msal_flutter")
            channel.setMethodCallHandler(MsalFlutterPlugin())
            activity = registrar.activity()
        }

    }

    fun getAuthCallback(result: Result): AuthenticationCallback {
        Log.d("MsalFlutter", "Getting the auth callback object")
        return object : AuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Log.d("MsalFlutter", "Authentication successful")

                loadAccounts(result)

                Handler(Looper.getMainLooper()).post {
                    result.success(authenticationResult.getAccessToken())
                }
            }

            override fun onError(exception: MsalException) {
                Log.d("MsalFlutter", "Error logging in!")
                Log.d("MsalFlutter", "${exception.message}")
                Handler(Looper.getMainLooper()).post {
                    result.error("AUTH_ERROR", "Authentication failed", exception.localizedMessage)
                }
            }

            override fun onCancel() {
                Log.d("MsalFlutter", "Cancelled")
                Handler(Looper.getMainLooper()).post {
                    result.error("CANCELLED", "User cancelled", null)
                }
            }
        }
    }


    private fun getApplicationCreatedListener(result: Result): IPublicClientApplication.IMultipleAccountApplicationCreatedListener {
        Log.d("MsalFlutter", "Getting the created listener")
        Log.d("MsalFlutter", "${activity.getApplicationContext().getPackageName()}")

        return object : IPublicClientApplication.IMultipleAccountApplicationCreatedListener {

            override fun onCreated(application: IMultipleAccountPublicClientApplication?) {
                Log.d("MsalFlutter", "Created successfully")
                msalApp = application as MultipleAccountPublicClientApplication
                result.success(true)

            }

            override fun onError(exception: MsalException) {
                Log.d("MsalFlutter", "Initialize error")
                Log.d("MsalFlutter", "${exception.message}")
                result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
            }
        }
    }

    /**
     * Callback used in for silent acquireToken calls.
     */
    private fun getAuthSilentCallback(result: Result): SilentAuthenticationCallback {
        return object : SilentAuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Log.d("MsalFlutter", "Authentication successful")

                loadAccounts(result)

                Handler(Looper.getMainLooper()).post {
                    result.success(authenticationResult.getAccessToken())
                }
            }

            override fun onError(exception: MsalException?) {
                Log.d("MsalFlutter", "Initialize error")
                result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
            }
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "msal_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val scopesArg: ArrayList<String>? = call.argument("scopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
//        val clientId: String? = call.argument("clientId")
        val authority: String? = call.argument("authority")
        val microsoftConfigFilePath: String? = call.argument("microsoftConfigFilePath")

        Log.d("MsalFlutter", "Got scopes: $scopes")
//        Log.d("MsalFlutter", "Got cleintId: $clientId")
        Log.d("MsalFlutter", "Got authority: $authority")
        Log.d("MsalFlutter", "Got microsoftConfigFile: $microsoftConfigFilePath")

        when (call.method) {
            "logout" -> Thread(Runnable { logout(result) }).start()
            "initialize" -> initialize(microsoftConfigFilePath, result)
            "acquireToken" -> Thread(Runnable { acquireToken(scopes, result) }).start()
            "acquireTokenSilent" -> Thread(Runnable { acquireTokenSilentAsync(scopes, result) }).start()
            else -> result.notImplemented()
        }

    }

    /**
     * Load currently signed-in accounts, if there's any.
     */
    private fun loadAccounts( result: Result) {
        Log.d("MsalFlutter", "load accounts called")
//
        // check if client has been initialized
        if (!isClientInitialized()) {
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
            }
        }


        msalApp.getAccounts(object : LoadAccountsCallback {
            override fun onTaskCompleted(result: List<IAccount>) {
                accountList = result
            }

            override fun onError(exception: MsalException) {
                Log.d("MsalFlutter", "Initialize error")
                result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
            }
        })
    }


    private fun acquireToken(scopes: Array<String>?, result: Result) {
        Log.d("MsalFlutter", "acquire token called")
//
        // check if client has been initialized
        if (!isClientInitialized()) {
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
            }
        }
//
        //check scopes
        if (scopes == null) {
            Log.d("MsalFlutter", "no scope")
            result.error("NO_SCOPE", "Call must include a scope", null)
            return
        }

        //acquire the token
        msalApp.acquireToken(activity, scopes, getAuthCallback(result))
    }

    private fun acquireTokenSilentAsync(scopes: Array<String>?, result: Result) {
        Log.d("MsalFlutter", "Called acquire token silent")

        // check if client has been initialized
        if (!isClientInitialized()) {
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
            }
        }

        //check the scopes
        if (scopes == null) {
            Log.d("MsalFlutter", "no scope")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_SCOPE", "Call must include a scope", null)
            }
            return
        }

        if (accountList != null) {
            // i will fix this bug later.
            return
        }


        val selectedAccount = accountList!![0]

//
        //acquire the token and return the result
        msalApp.acquireTokenSilentAsync(
                scopes,
                selectedAccount,
                selectedAccount.getAuthority(),
                getAuthSilentCallback(result)
        )
    }

    private fun initialize(microsoftConfigFile: String?, result: Result) {

        //if already initialized, ensure clientid hasn't changed
        if (isClientInitialized()) {
            Log.d("MsalFlutter", "Client already initialized.")
            result.error("CHANGED_CLIENTID", "Attempting to initialize with multiple clientIds.", null)
        }

        val mConfigFile = File(microsoftConfigFile!!)

        PublicClientApplication.createMultipleAccountPublicClientApplication(activity.getApplicationContext(), mConfigFile, getApplicationCreatedListener(result))

    }




    private fun logout(result: Result) {
//        while(msalApp.accounts.any()){
//            Log.d("MsalFlutter","Removing old account")
//            msalApp.removeAccount(msalApp.accounts.first())
//        }
//        Handler(Looper.getMainLooper()).post {
//            result.success(true)
//        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

}
