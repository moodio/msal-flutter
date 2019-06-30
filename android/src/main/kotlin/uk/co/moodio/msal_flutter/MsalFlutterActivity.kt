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

        //get the config
        val clientId = getString(R.string.msal_clientid);
        val authority = getString(R.string.msal_authority);
        
        //setup the msal object
        msalApp = PublicClientApplication(this.applicationContext, 
            getString(R.string.msal_clientid),
            "https://login.microsoftonline.com/tfp/msalfluttertest.onmicrosoft.com/B2C_1_sisu")

            msalApp.mPublicClientApplicationConfig.get

        val scopes = intent.getStringArrayExtra("scopes")
        val method = intent.getStringExtra("method")

        Log.d("MooAuth","Got scopes: $scopes")
        setContentView(R.layout.msalflutter)

        when(method){
            "acquireToken" -> acquireToken(scopes)
            "acquireTokenSilent" -> acquireTokenSilentAsync(scopes)
        }
    }

    override fun onResume(){
        super.onResume()
        Log.d("MooAuth","Resumed")
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d("MooAuth","Activity resulted")
        msalApp.handleInteractiveRequestRedirect(requestCode, resultCode, data)
    }

    private fun acquireToken(scopes: Array<String>){
        Log.d("MooAuth", "called acquire token from activity with scopes $scopes")
        Log.i("MooAuth","Loading acquire token")

        val onComplete: () -> Unit = { finish() }
        msalApp.acquireToken(this, scopes, MsalFlutterPlugin.getAuthInteractiveCallback(onComplete))
    }

    private fun acquireTokenSilentAsync (scopes: Array<String>)
    {
        Log.i("MooAuth","Loading acquire token silent")

        if(msalApp.accounts.isEmpty()){
            Log.d("MooAuth", "No accounts available for using acquire token silently with scopes $scopes")
            MsalFlutterPlugin.lastResult.error("NO_ACCOUNTS","No user accounts exist", null)
            finish()
        }

        val onComplete: () -> Unit = { finish() }
        msalApp.acquireTokenSilentAsync(scopes, msalApp.accounts[0], MsalFlutterPlugin.getAuthInteractiveCallback(onComplete))
    }

}
