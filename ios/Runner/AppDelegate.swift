import UIKit
import Flutter
import CryptoSwift
import Foundation
import CoreData
import StoreKit
import ContactsUI
import WebKit
import MessageUI
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    
    static let secretKey = "12345abcdefghtuv"
    static let encyptedKey = "abc"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        debugPrint("app folder path is \(NSHomeDirectory())")
       // FirebaseApp.configure()

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let nativeMethodChannel = FlutterMethodChannel(name: "RATE_REVIEW_APP_METHOD_CHANNEL",
                                                       binaryMessenger: controller.binaryMessenger)
        
        nativeMethodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, flutterResultCallBack: @escaping FlutterResult) -> Void in
            
            if (call.method == "getToken") {
                return self!.getToken(call: call, result: flutterResultCallBack)
            }
            else if (call.method == "getEncryptionKey") {
                flutterResultCallBack(AppDelegate.encyptedKey)
            }
            else if (call.method == "getSecretKey") {
                flutterResultCallBack(AppDelegate.secretKey)
            }
            else if (call.method == "getEncryptedPassword") {
                return self!.getEncryptedPassword(call: call, result: flutterResultCallBack)
            }
            else if(call.method == "readSharedPref"){
                let arguments = call.arguments
                let sharepref = (arguments as AnyObject)["sharePref"] as? String
                flutterResultCallBack( UserDefaults.standard.string(forKey:sharepref ?? ""))
                return
            }else if(call.method == "removeSharedPref"){
                let arguments = call.arguments
                UserDefaults.standard.removeObject(forKey: ((arguments as AnyObject)["sharePref"] as? String)!)
                flutterResultCallBack(true)
                return
            }else  if(call.method == "saveSharedPref"){
                let arguments = call.arguments
                let sharepref = (arguments as AnyObject)["sharePref"] as? String
                let json = (arguments as AnyObject)["json"] as? String
                UserDefaults.standard.set(json, forKey: sharepref ?? "")
                flutterResultCallBack(true)
                return
            }
            
            //MARK:- internetConnectivity
            else if(call.method == "internetConnectivity"){
                flutterResultCallBack(Reachability.isConnectedToNetwork())
                return
            }
            else if (call.method == "getPlatformDetail") {
                return flutterResultCallBack(
                    [
                        "packageName": Bundle.main.bundleIdentifier ?? NSNull(),
                        "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? NSNull(),
                        "buildNumber": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? NSNull()
                    ])
            }
            //MARK:- Flutter Method Not Implemented
            else {
                flutterResultCallBack(FlutterMethodNotImplemented)
                return
            }
            
        })
        
       

        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(1))
                
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    static func registerPlugins(with registry: FlutterPluginRegistry) {
        GeneratedPluginRegistrant.register(with: registry)
    }
    
//    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler(.alert)
//    }
    
    fileprivate func getToken(call: FlutterMethodCall, result: FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        var personId = args?["data"] as? String
        
        let uuid = UUID().uuidString
        personId = personId! + uuid
        let enc = try! personId!.aesEncrypt()
        return result(enc)
    }
    
    fileprivate func getEncryptedPassword(call: FlutterMethodCall, result: FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        var personId = args?["data"] as? String
        let password = args?["password"] as? String
        
        personId = personId! + password!
        let enc = try! personId!.aesEncrypt()
        return result(enc)
    }
}

extension String {
    
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    var pathExtension: String {
        return fileURL.pathExtension
    }
    
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
    
    func aesEncrypt() throws -> String{
        let mKey: Array<UInt8> = "12345abcdefghtuv".bytes
//        let mKey: [UInt8] = Array("12345abcdefghtuv".utf8)
        let dataToEncrypt: [UInt8] = Array(self.utf8)
        
        let iv = AES.randomIV(12)
        
        let enc = try AES(key: mKey, blockMode: GCM(iv: iv, mode: .combined), padding: .noPadding).encrypt(dataToEncrypt)
        let encData = NSData(bytes: enc, length: Int(enc.count))
        let base64String: String = encData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0));
        let result = String(base64String)
        print(result)
        return result
        
    }
    
    
//    public static String encryptMsg_New(String privateString, SecretKey skey) throws Exception {
//           byte[] iv = new byte[GCM_IV_LENGTH];
//           (new SecureRandom()).nextBytes(iv);
//           Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
//           GCMParameterSpec ivSpec = null;
//           if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//               ivSpec = new GCMParameterSpec(GCM_TAG_LENGTH * Byte.SIZE, iv);
//               cipher.init(Cipher.ENCRYPT_MODE, skey, ivSpec);
//           }
//           byte[] ciphertext = cipher.doFinal(privateString.getBytes("UTF-8"));
//           byte[] encrypted = new byte[iv.length + ciphertext.length];
//           System.arraycopy(iv, 0, encrypted, 0, iv.length);
//           System.arraycopy(ciphertext, 0, encrypted, iv.length, ciphertext.length);
//           String encoded = Base64.encodeToString(encrypted, Base64.DEFAULT);
//           return encoded;
//       }
    
    func aesDecrypt() throws -> String {
        let password: [UInt8] = Array("12345abcdefghtuv".utf8)
        
        let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions.init(rawValue: 0))
        let dec = try AES(key: password, blockMode:ECB()).decrypt(data!.bytes)
        let decData = NSData(bytes: dec, length: Int(dec.count))
        let result = String(data: decData as Data, encoding: String.Encoding.utf8)
        return String(result!)
    }
}

