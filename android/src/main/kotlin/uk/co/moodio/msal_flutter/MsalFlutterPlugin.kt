package uk.co.moodio.msal_flutter

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.microsoft.identity.client.*
import com.microsoft.identity.client.IPublicClientApplication.IMultipleAccountApplicationCreatedListener
import com.microsoft.identity.client.IPublicClientApplication.LoadAccountsCallback
import com.microsoft.identity.client.exception.MsalClientException
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.exception.MsalServiceException
import com.microsoft.identity.client.exception.MsalUiRequiredException
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


@Suppress("SpellCheckingInspection")
class MsalFlutterPlugin : MethodCallHandler {
    companion object {
        lateinit var mainActivity: Activity
        lateinit var msalApp: IMultipleAccountPublicClientApplication
        lateinit var accountList: List<IAccount>

        fun isClientInitialized() = ::msalApp.isInitialized

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            // Log.d("MsalFlutter","Registering plugin")
            val channel = MethodChannel(registrar.messenger(), "msal_flutter")
            channel.setMethodCallHandler(MsalFlutterPlugin())
            mainActivity = registrar.activity()
        }

        fun getAuthCallback(result: Result): AuthenticationCallback {

            return object : AuthenticationCallback {
                override fun onSuccess(authenticationResult: IAuthenticationResult) {
                    Handler(Looper.getMainLooper()).post {
                        result.success(authenticationResult.accessToken)
                    }
                }

                override fun onError(exception: MsalException) {
                    Handler(Looper.getMainLooper()).post {
                        result.error("AUTH_ERROR", "Authentication failed", exception.localizedMessage)
                    }
                }

                override fun onCancel() {
                    Handler(Looper.getMainLooper()).post {
                        result.error("CANCELLED", "User cancelled", null)
                    }
                }
            }
        }

        /**
         * Callback used in for silent acquireToken calls.
         */
        fun getAuthSilentCallback(result: Result): SilentAuthenticationCallback {
            return object : SilentAuthenticationCallback {
                override fun onSuccess(authenticationResult: IAuthenticationResult) {
                    Log.d("MSAL_FLUTTER", "Successfully authenticated")
                    Handler(Looper.getMainLooper()).post {
                        result.success(authenticationResult.accessToken)
                    }
                }

                override fun onError(exception: MsalException) {
                    /* Failed to acquireToken */
                    Log.d("MSAL_FLUTTER", "Authentication failed: $exception")
                    if (exception is MsalClientException) {
                        result.error("NO_SCOPE", "Call must include a scope", exception.localizedMessage)
                    } else if (exception is MsalServiceException) {
                        result.error("NO_SCOPE", exception.localizedMessage, exception.localizedMessage)
                    } else if (exception is MsalUiRequiredException) {
                        result.error("NO_SCOPE", "Call must include a scope", exception.localizedMessage)
                    }
                }
            }
        }

        private fun getApplicationCreatedListener(result: Result): IMultipleAccountApplicationCreatedListener {

            return object : IMultipleAccountApplicationCreatedListener {
                override fun onCreated(application: IMultipleAccountPublicClientApplication) {

                        msalApp = application
                        result.success(true)

                }

                override fun onError(exception: MsalException?) {
                    Log.d("MsalFlutter", "Initialize error")
                    result.error("INIT_ERROR", "Error initializting client", exception?.localizedMessage)
                }
            }
        }


    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val scopesArg: ArrayList<String>? = call.argument("scopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
        val clientId: String? = call.argument("clientId")
        val authority: String? = call.argument("authority")

        when (call.method) {
            "logout" -> Thread(Runnable { logout(result) }).start()
            "initialize" -> initialize(clientId, authority, result)
            "loadAccounts" -> Thread(Runnable { loadAccounts(result) }).start()
            "acquireToken" -> Thread(Runnable { acquireToken(scopes, result) }).start()
            "acquireTokenSilent" -> Thread(Runnable { acquireTokenSilent(scopes, result) }).start()
            else -> result.notImplemented()
        }

    }

    private fun acquireToken(scopes: Array<String>?, result: Result) {
        // check if client has been initialized
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
            }
        }

        //check scopes
        if (scopes == null) {
            result.error("NO_SCOPE", "Call must include a scope", null)
            return
        }

        //remove old accounts
        while (msalApp.accounts.any()) {
            msalApp.removeAccount(msalApp.accounts.first())
        }

        //acquire the token
        msalApp.acquireToken(mainActivity, scopes, getAuthCallback(result))
    }

    private fun acquireTokenSilent(scopes: Array<String>?, result: Result) {
        // check if client has been initialized

        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error("NO_CLIENT", "Client must be initialized before attempting to acquire a token.", null)
            }
        }

        //check the scopes
        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("NO_SCOPE", "Call must include a scope", null)
            }
            return
        }

        //ensure accounts exist
        if (accountList?.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", null)
            }
            return
        }
        val selectedAccount: IAccount = accountList.first();
        //acquire the token and return the result
        val sc = scopes.map { s -> s.toLowerCase() }.toTypedArray()

        msalApp.acquireTokenSilentAsync(sc, selectedAccount, selectedAccount.authority, getAuthSilentCallback(result))

    }


    private fun initialize(clientId: String?, authority: String?, result: Result) {
        //ensure clientid provided
        if (clientId == null) {
            result.error("NO_CLIENTID", "Call must include a clientId", null)
            return
        }

        //if already initialized, ensure clientid hasn't changed
        if (isClientInitialized()) {
            if (msalApp.configuration.clientId == clientId) {
                result.success(true)
            } else {
                result.error("CHANGED_CLIENTID", "Attempting to initialize with multiple clientIds.", null)
            }
        }
        if(!isClientInitialized()) {
            // if authority is set, create client using it, otherwise use default
            PublicClientApplication.createMultipleAccountPublicClientApplication(mainActivity.applicationContext,
                    R.raw.msal_default_config, getApplicationCreatedListener(result))
        }

    }

    /**
     * Load currently signed-in accounts, if there's any.
     */
    private fun loadAccounts(result: Result) {

        msalApp.getAccounts(object : LoadAccountsCallback {

            override fun onTaskCompleted(resultList: List<IAccount>) {
                accountList = resultList
                result.success(true)
            }

            override fun onError(exception: MsalException) {
                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", exception)
            }
        })
    }


    private fun logout(result: Result) {
        if(!isClientInitialized()){
            Handler(Looper.getMainLooper()).post {
                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", null)
            }
            return
        }

        if (accountList?.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", null)
            }
            return
        }

        msalApp.removeAccount(accountList.first(), object : IMultipleAccountPublicClientApplication.RemoveAccountCallback{
            override fun onRemoved() {
                Thread(Runnable { loadAccounts(result) }).start()
            }

            override fun onError(exception: MsalException) {
                result.error("NO_ACCOUNT", "No account is available to acquire token silently for", exception)
            }
        })

    }
}


