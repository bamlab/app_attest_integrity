package com.theodo.app_attest_integrity

import AppAttestIntegrityApi
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AppAttestIntegrityPlugin: FlutterPlugin, AppAttestIntegrityApi {
  private var context: Context? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    AppAttestIntegrityApi.setUp(flutterPluginBinding.binaryMessenger, this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    AppAttestIntegrityApi.setUp(binding.binaryMessenger, null)
    context = null
  }

  override fun getPlatformVersion(): String = "Android ${android.os.Build.VERSION.RELEASE}"

}
