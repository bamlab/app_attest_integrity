package com.theodo.app_attest_integrity

import AppAttestIntegrityApi
import FlutterError
import GenerateAttestationResponsePigeon
import android.content.Context
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin


class AppAttestIntegrityPlugin : FlutterPlugin, AppAttestIntegrityApi {
    private var context: Context? = null

    var standardIntegrityManager: StandardIntegrityManager? = null
    var integrityTokenProvider: StandardIntegrityTokenProvider? = null


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        AppAttestIntegrityApi.setUp(flutterPluginBinding.binaryMessenger, this)
        context = flutterPluginBinding.applicationContext
        standardIntegrityManager = IntegrityManagerFactory.createStandard(context)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AppAttestIntegrityApi.setUp(binding.binaryMessenger, null)
        context = null
    }

    override fun getPlatformVersion(): String = "Android ${android.os.Build.VERSION.RELEASE}"

    override fun androidPrepareIntegrityServer(
        cloudProjectNumber: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        standardIntegrityManager?.prepareIntegrityToken(
            PrepareIntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build()
        )?.addOnSuccessListener { tokenProvider: StandardIntegrityTokenProvider ->
            integrityTokenProvider = tokenProvider
            callback(Result.success(Unit))
        }?.addOnFailureListener { exception: Exception? ->
            callback(Result.failure(FlutterError("failed to prepare Integrity Token: ${exception?.message ?: "no details"}")))
        }
    }

    override fun iOSgenerateAttestation(
        challenge: String,
        callback: (Result<GenerateAttestationResponsePigeon?>) -> Unit
    ) {
        callback(Result.success(null))
    }

    override fun verify(clientData: String, keyID: String, callback: (Result<String>) -> Unit) {
        callback(Result.failure(FlutterError("Unimplemented method")))
    }

}
