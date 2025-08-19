package com.theodo.app_attest_integrity

import AppAttestIntegrityApi
import FlutterError
import GenerateAssertionResponsePigeon
import android.content.Context
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin


class AppAttestIntegrityPlugin: FlutterPlugin, AppAttestIntegrityApi {
  private var context: Context? = null

  var standardIntegrityManager: StandardIntegrityManager? = null
  var integrityTokenProvider: StandardIntegrityTokenProvider?=null


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

  override fun androidPrepareIntegrityServer(cloudProjectNumber: Long) {
    standardIntegrityManager?.prepareIntegrityToken(
      PrepareIntegrityTokenRequest.builder()
        .setCloudProjectNumber(cloudProjectNumber)
        .build()
    )?.addOnSuccessListener { tokenProvider: StandardIntegrityTokenProvider ->
        integrityTokenProvider = tokenProvider
      }?.addOnFailureListener { exception: Exception? ->
        throw FlutterError("failed to prepare Integrity Token: ${exception?.message?:"no details"}" )
      }
  }

  override fun iOSgenerateAttestation(challenge: String): GenerateAssertionResponsePigeon? {
    return null
  }

}
