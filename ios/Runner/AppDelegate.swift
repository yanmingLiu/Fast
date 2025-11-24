import Flutter
import UIKit
import FBSDKCoreKit
import AppTrackingTransparency
import CoreTelephony

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Facebook 基础初始化
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    // Flutter UIScene 隐式引擎初始化
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        // Register plugins with `engineBridge.pluginRegistry`
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        // Create method channels with `engineBridge.applicationRegistrar.messenger()`
        let channel = FlutterMethodChannel(
            name: "facebook_sdk_channel",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
        
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            switch call.method {
                
            case "initializeFacebookSDK":
                guard
                    let args = call.arguments as? [String: Any],
                    let appId = args["appId"] as? String,
                    let clientToken = args["clientToken"] as? String
                else {
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENTS",
                            message: "Missing appId or clientToken",
                            details: nil
                        )
                    )
                    return
                }
                
                // Facebook SDK 配置
                Settings.shared.appID = appId
                Settings.shared.clientToken = clientToken
                Settings.shared.loggingBehaviors = [
                    .appEvents, .networkRequests, .developerErrors, .informational
                ]
                
                if #available(iOS 14, *) {
                    switch ATTrackingManager.trackingAuthorizationStatus {
                    case .authorized:
                        Settings.shared.isAdvertiserTrackingEnabled = true
                    case .notDetermined:
                        break
                    default:
                        Settings.shared.isAdvertiserTrackingEnabled = false
                    }
                }
                
                AppEvents.shared.logEvent(.init("test_init"))
                AppEvents.shared.activateApp()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    AppEvents.shared.flush()
                }
                
                result("Facebook SDK initialized successfully")
                
            case "isFacebookSDKInitialized":
                let ok = Settings.shared.appID != nil && !(Settings.shared.appID!.isEmpty)
                result(ok)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        
        // sim check
        let simChannel = FlutterMethodChannel(
            name: "sim_check",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
        
        simChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            if call.method == "hasSimCard" {
                result(self.hasSim())
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func hasSim() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        let hasSim = networkInfo.serviceCurrentRadioAccessTechnology?.values.count ?? 0 != 0
        return hasSim
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
