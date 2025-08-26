import Flutter
import UIKit
import FBSDKCoreKit
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // FB SDK 初始化
        let reslut = ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // 设置Facebook SDK延迟初始化的方法通道
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let facebookChannel = FlutterMethodChannel(name: "facebook_sdk_channel",
                                                   binaryMessenger: controller.binaryMessenger)
        
        facebookChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "initializeFacebookSDK" {
                guard let args = call.arguments as? [String: Any],
                      let appId = args["appId"] as? String,
                      let clientToken = args["clientToken"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing appId or clientToken", details: nil))
                    return
                }
                
                // 配置Facebook SDK
                Settings.shared.appID = appId
                Settings.shared.clientToken = clientToken
                
                Settings.shared.loggingBehaviors = [.appEvents, .networkRequests, .developerErrors, .informational]
                
                print("初始化Facebook SDK appId:\(appId) clientToken:\(clientToken)");
                
                if #available(iOS 14, *) {
                    if (ATTrackingManager.trackingAuthorizationStatus == .authorized){
                        Settings.shared.isAdvertiserTrackingEnabled = true
                    } else if(ATTrackingManager.trackingAuthorizationStatus == .notDetermined){
                        
                    } else {
                        Settings.shared.isAdvertiserTrackingEnabled = false
                    }
                }
                
                AppEvents.shared.logEvent(.init("test_event_init_succ"))
                
                // 添加应用事件激活
                AppEvents.shared.activateApp()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    AppEvents.shared.flush()
                }
                
                result("Facebook SDK initialized successfully")
            } else if call.method == "isFacebookSDKInitialized" {
                // 检查Facebook SDK是否已初始化
                let isInitialized = Settings.shared.appID != nil && !Settings.shared.appID!.isEmpty
                result(isInitialized)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        return true
    }
    
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
