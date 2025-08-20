import Flutter
import UIKit
import DeviceCheck
import CryptoKit

public class AppAttestIntegrityPlugin: NSObject, FlutterPlugin, AppAttestIntegrityApi {

    public static func register(with registrar: FlutterPluginRegistrar) {
      let messenger: FlutterBinaryMessenger = registrar.messenger()
      let api: AppAttestIntegrityApi & NSObjectProtocol = AppAttestIntegrityPlugin.init()

      AppAttestIntegrityApiSetup.setUp(binaryMessenger: messenger, api: api)
    }

    public func getPlatformVersion() throws -> String? {
           return "iOS " + UIDevice.current.systemVersion
    }
    
    public func androidPrepareIntegrityServer(cloudProjectNumber: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(Void()))
    }
    
     func iOSgenerateAttestation(
      challenge: String,
      completion: @escaping (Result<GenerateAssertionResponsePigeon?, Error>) -> Void
     ) {
         // App Attest requires iOS 14+
         guard #available(iOS 14.0, *) else {
             completion(.failure(PigeonError(code: "unavailable", message: "App Attest requires iOS 14.0+", details: nil)))
             return
         }
         
         let service = DCAppAttestService.shared
         guard service.isSupported else {
             completion(.failure(PigeonError(code: "unsupported", message: "App Attest is not supported on this device.", details: nil)))
             return
         }
         
         service.generateKey { keyId, genError in
             guard genError == nil, let keyId = keyId else {
                 let error = genError as NSError?
                 completion(.failure(PigeonError(
                    code: "generate_key_failed",
                    message: "Failed to generate App Attest key.",
                    details: ["domain": error?.domain ?? "", "code": error?.code ?? -1, "desc": error?.localizedDescription ?? ""]
                 )))
                 return
             }
             
             let clientDataHash = Data(SHA256.hash(data: Data(challenge.utf8)))
             
             service.attestKey(keyId, clientDataHash: clientDataHash) { attestationObject, attestError in
                 guard attestError == nil, let attestationObject = attestationObject else {
                     let error = attestError as NSError?
                     completion(.failure(PigeonError(
                        code: "attest_key_failed",
                        message: "Failed to attest App Attest key.",
                        details: ["domain": error?.domain ?? "", "code": error?.code ?? -1, "desc": error?.localizedDescription ?? ""]
                     )))
                     return
                 }
                 
                 let response = GenerateAssertionResponsePigeon(
                    attestation: attestationObject.base64EncodedString(),
                    keyId: keyId
                 )
                 completion(.success(response))
             }
         }
     }
}


