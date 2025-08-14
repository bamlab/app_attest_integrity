import Flutter
import UIKit

public class AppAttestIntegrityPlugin: NSObject, FlutterPlugin, AppAttestIntegrityApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let messenger: FlutterBinaryMessenger = registrar.messenger()
      let api: AppAttestIntegrityApi & NSObjectProtocol = AppAttestIntegrityPlugin.init()

      AppAttestIntegrityApiSetup.setUp(binaryMessenger: messenger, api: api)
  }

    public func getPlatformVersion() throws -> String? {
           return "iOS " + UIDevice.current.systemVersion
       }
}
