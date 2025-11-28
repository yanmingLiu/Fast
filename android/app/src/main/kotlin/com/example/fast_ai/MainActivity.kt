package com.example.fast_ai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import com.facebook.LoggingBehavior

import android.content.Context
import android.telephony.TelephonyManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "facebook_sdk_channel"
    private val SIM_CHANNEL = "sim_check"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeFacebookSDK" -> {
                    try {
                        val appId = call.argument<String>("appId")
                        val clientToken = call.argument<String>("clientToken")

                        // 禁用自动初始化
                        FacebookSdk.setAutoInitEnabled(false)

                        if (appId != null && clientToken != null) {
                            // 设置应用ID和客户端令牌
                            FacebookSdk.setApplicationId(appId)
                            FacebookSdk.setClientToken(clientToken)
                            FacebookSdk.sdkInitialize(applicationContext)
                            FacebookSdk.setAutoInitEnabled(true)
                            FacebookSdk.fullyInitialize()

                            // 激活应用事件记录
                            AppEventsLogger.activateApp(application)

                            println("初始化Facebook SDK appId:$appId clientToken:$clientToken")

                            // 设置日志行为，类似iOS的loggingBehaviors设置
                            FacebookSdk.setIsDebugEnabled(true)
                            FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS)
                            FacebookSdk.addLoggingBehavior(LoggingBehavior.REQUESTS)
                            FacebookSdk.addLoggingBehavior(LoggingBehavior.DEVELOPER_ERRORS)
                            FacebookSdk.addLoggingBehavior(LoggingBehavior.INCLUDE_ACCESS_TOKENS)

                            val logger = AppEventsLogger.newLogger(this)
                            logger.logEvent("sdk_android_init")

                            result.success("Facebook SDK initialized successfully")
                        } else {
                            result.error(
                                "INVALID_ARGUMENTS",
                                "App ID and Client Token are required",
                                null
                            )
                        }
                    } catch (e: Exception) {
                        result.error(
                            "INITIALIZATION_ERROR",
                            "Failed to initialize Facebook SDK: ${e.message}",
                            null
                        )
                    }
                }

                "isFacebookSDKInitialized" -> {
                    try {
                        val isInitialized = FacebookSdk.isInitialized()
                        result.success(isInitialized)
                    } catch (e: Exception) {
                        result.error(
                            "CHECK_ERROR",
                            "Failed to check Facebook SDK status: ${e.message}",
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SIM_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "hasSimCard") {
                    val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                    val state = telephonyManager.simState
                    result.success(state == TelephonyManager.SIM_STATE_READY)
                } else {
                    result.notImplemented()
                }
            }
    }
}

