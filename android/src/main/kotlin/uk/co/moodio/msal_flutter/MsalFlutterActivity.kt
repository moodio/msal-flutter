package uk.co.moodio.msal_flutter

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
//import io.flutter.plugin.common.MethodChannel.Result
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalException
import kotlinx.android.synthetic.main.msalflutter.*

class MsalFlutterActivity : Activity()
{
    companion object {
        lateinit var msalApp : PublicClientApplication
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MsalFlutter","created activity")
        setContentView(R.layout.msalflutter)
    }

    override fun onResume(){
        super.onResume()
        Log.d("MsalAuth","Resumed")
    }

    // override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    //     super.onActivityResult(requestCode, resultCode, data)
    //     Log.d("MsalAuth","Activity resulted")
    //     MsalFlutterPlugin.msalApp.handleInteractiveRequestRedirect(requestCode, resultCode, data)
    // }

    // private fun acquireTokenSilentAsync (scopes: Array<String>)
    // {
    //     Log.i("MooAuth","Loading acquire token silent")

    //     if(msalApp.accounts.isEmpty()){
    //         Log.d("MooAuth", "No accounts available for using acquire token silently with scopes $scopes")
    //         MsalFlutterPlugin.lastResult.error("NO_ACCOUNTS","No user accounts exist", null)
    //         finish()
    //     }

    //     val onComplete: () -> Unit = { finish() }
    //     msalApp.acquireTokenSilentAsync(scopes, msalApp.accounts[0], MsalFlutterPlugin.getAuthInteractiveCallback(onComplete))
    // }

}
