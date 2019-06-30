package uk.co.moodio.msal_flutter

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.microsoft.identity.client.AuthenticationCallback
import com.microsoft.identity.client.AuthenticationResult
import com.microsoft.identity.client.exception.MsalException
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

@Suppress("SpellCheckingInspection")
class MsalFlutterPlugin: MethodCallHandler {
    companion object
    {
        lateinit var mainActivity : Activity
        lateinit var lastResult : Result

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "msal_flutter")
            channel.setMethodCallHandler(MsalFlutterPlugin())
            mainActivity = registrar.activity()
        }

        fun getAuthInteractiveCallback(onComplete: () -> Unit ) : AuthenticationCallback
        {
            return object : AuthenticationCallback
            {
                @Override
                override fun onSuccess(authenticationResult : AuthenticationResult){
                    Log.d("MooAuth", "Authentication successful")
                    MsalFlutterPlugin.lastResult.success(authenticationResult.accessToken)
                    onComplete()
                }

                @Override
                override fun onError(exception : MsalException)
                {
                    Log.d("MooAuth","Error logging in!")
                    Log.d("MooAuth", exception.message)
                    onComplete()
                }

                @Override
                override fun onCancel(){
                    Log.d("MooAuth", "Cancelled")
                    onComplete()
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result)
    {
        lastResult = result

        val args = call.arguments as ArrayList<String>
        val scopes : Array<String> = args.toTypedArray()

        if(scopes == null){
            Log.d("MooAuth", "no scope")

            result.error("NO_SCOPE","Call must include a scope", null)
            return
        }
        Log.d("MooAuth","supplied scopes are ${call.arguments}")
        Log.d("MooAuth", "supplied scopes cast to arraylist as $args")
        Log.d("MooAuth", "scopes cast to array as ${scopes.joinToString(" - ")}")

        Log.d("MooAuth", "about to call when on call.method ${call.method}")

        when(call.method){
            "acquireToken", "acquireTokenSilent" -> acquireToken(call.method, scopes)
            else -> result.notImplemented()
        }

    }

    private fun acquireToken(method: String, scopes : Array<String>)
    {
        Log.d("MooAuth", "called acquire token from plug with scopes $scopes")
        val intent = Intent(mainActivity, MsalFlutterActivity::class.java)
        intent.putExtra("method", method)
        intent.putExtra("scopes", scopes)
        mainActivity.startActivity(intent)
    }
}
