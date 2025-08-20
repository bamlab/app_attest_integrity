package com.theodo.app_attest_integrity

import AppAttestIntegrityApi
import android.util.Base64
import FlutterError
import GenerateAttestationResponsePigeon
import android.content.Context
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityToken
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenProvider
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.security.MessageDigest

class AppAttestIntegrityPlugin : FlutterPlugin, AppAttestIntegrityApi {
    private var context: Context? = null
    private var standardIntegrityManager: StandardIntegrityManager? = null

    private var integrityTokenProvider: StandardIntegrityTokenProvider? = null
    private var cloudProjectNumber: Long? = null


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        AppAttestIntegrityApi.setUp(flutterPluginBinding.binaryMessenger, this)
        context = flutterPluginBinding.applicationContext
        standardIntegrityManager = IntegrityManagerFactory.createStandard(context)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AppAttestIntegrityApi.setUp(binding.binaryMessenger, null)
        context = null
        integrityTokenProvider = null
        cloudProjectNumber = null
    }

    override fun getPlatformVersion(): String = "Android ${android.os.Build.VERSION.RELEASE}"

    override fun androidPrepareIntegrityServer(
        cloudProjectNumber: Long, callback: (Result<Unit>) -> Unit
    ) {
        getProvider(cloudProjectNumber) {
            it.onSuccess { provider ->
                integrityTokenProvider = provider
                callback(Result.success(Unit))
            }.onFailure { error -> callback(Result.failure(error)) }
        }
    }

    override fun iOSgenerateAttestation(
        challenge: String, callback: (Result<GenerateAttestationResponsePigeon?>) -> Unit
    ) {
        callback(Result.success(null))
    }

    override fun verify(
        clientData: String,
        keyID: String,
        cloudProjectNumber: Long?,
        callback: (Result<String>) -> Unit
    ) {
        val provider = integrityTokenProvider
        if (provider == null) {
            if (cloudProjectNumber == null) {
                callback(
                    Result.failure(
                        FlutterError(
                            "0",
                            "cloudProjectNumber not set. "
                                    + "If possible, call androidPrepareIntegrityServer "
                                    + "before verify. Otherwise, provide a cloudProjectNumber "
                                    + "when calling verify"
                        )
                    )
                )
                return
            }
            getProvider(cloudProjectNumber) {
                it.onSuccess { provider ->
                    integrityTokenProvider = provider
                    getToken(provider, clientData, callback)
                }.onFailure { error -> callback(Result.failure(error)) }
            }
            return
        }
        getToken(provider, clientData, callback)
    }


    private fun getProvider(
        cloudProjectNumber: Long, onDone: (result: Result<StandardIntegrityTokenProvider>) -> Unit
    ) {
        this.cloudProjectNumber = cloudProjectNumber
        standardIntegrityManager?.prepareIntegrityToken(
            PrepareIntegrityTokenRequest.builder().setCloudProjectNumber(cloudProjectNumber).build()
        )?.addOnSuccessListener { tokenProvider: StandardIntegrityTokenProvider ->
            onDone(Result.success(tokenProvider))
        }?.addOnFailureListener { exception: Exception? ->
            onDone(Result.failure(FlutterError("failed to prepare Integrity Token: ${exception?.message ?: "no details"}")))
        }
    }

    private fun getToken(
        provider: StandardIntegrityTokenProvider,
        clientData: String,
        onDone: (Result<String>) -> Unit
    ) {
        val requestHashDigest =
            MessageDigest.getInstance("SHA-256").digest(clientData.toByteArray(Charsets.UTF_8))
        val requestHash =
            Base64.encodeToString(requestHashDigest, Base64.NO_WRAP or Base64.NO_PADDING)


        val integrityTokenResponse = provider.request(
            StandardIntegrityTokenRequest.builder().setRequestHash(requestHash).build()
        )
        integrityTokenResponse.addOnSuccessListener { response: StandardIntegrityToken ->
            onDone(
                Result.success(
                    response.token()
                )
            )
        }.addOnFailureListener { exception: java.lang.Exception? ->
            onDone(
                Result.failure(
                    FlutterError("failed to generate token: ${exception?.message ?: "no details"}")
                )
            )
        }
    }
}