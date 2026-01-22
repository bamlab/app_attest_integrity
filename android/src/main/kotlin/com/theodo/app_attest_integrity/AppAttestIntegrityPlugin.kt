package com.theodo.app_attest_integrity

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Android Flutter plugin for app_attest_integrity.
 * 
 * This plugin exists to ensure the Play Integrity dependencies are included
 * in the app's APK. All actual functionality is implemented in Dart via JNI.
 */
class AppAttestIntegrityPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
