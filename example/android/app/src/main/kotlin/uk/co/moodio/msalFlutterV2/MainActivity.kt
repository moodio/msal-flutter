package uk.co.moodio.msalFlutterV2

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Bundle
import android.util.Log

import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import android.util.Base64
import android.content.Context

import android.content.pm.PackageManager.NameNotFoundException


import android.content.pm.PackageManager

import android.content.pm.PackageInfo




class MainActivity : FlutterActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))

        try {
            val info: PackageInfo = getPackageManager().getPackageInfo("uk.co.moodio.msalFlutterV2", PackageManager.GET_SIGNATURES)
            for (signature in info.signatures) {
                val md: MessageDigest = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                Log.d("KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT))
            }
        } catch (e: NameNotFoundException) {
            e.printStackTrace()
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        }
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        Log.d("flutterEngine", "flutterEngine")
    }

}
