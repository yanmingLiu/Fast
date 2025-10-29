##################################################
## Flutter 通用混淆规则（不混淆第三方 SDK）
##################################################

# 保留所有注解、签名、反射信息
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,Exceptions

# 保留所有实现 Parcelable 的类
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 保留 Serializable 类
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Flutter 基础
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Dart JNI、MethodChannel、EventChannel
-keep class * extends io.flutter.plugin.common.MethodCallHandler
-keep class * extends io.flutter.plugin.common.EventChannel$StreamHandler
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar

# Android 四大组件
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.Application

# View 构造函数
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Application / BuildConfig / R
-keep class **.BuildConfig { *; }
-keepclassmembers class **.R$* { public static <fields>; }

##################################################
## 不混淆第三方 SDK
##################################################

# Facebook SDK
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Google / Firebase / AdMob
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Adjust
-keep class com.adjust.sdk.** { *; }
-dontwarn com.adjust.sdk.**

# AppsFlyer
-keep class com.appsflyer.** { *; }
-dontwarn com.appsflyer.**

# TikTok / Pangle / ByteDance
-keep class com.bytedance.** { *; }
-dontwarn com.bytedance.**

# Facebook Audience Network (如有广告)
-keep class com.facebook.ads.** { *; }
-dontwarn com.facebook.ads.**

# Unity Ads / IronSource / TopOn / AppLovin
-keep class com.unity3d.ads.** { *; }
-dontwarn com.unity3d.ads.**
-keep class com.ironsource.** { *; }
-dontwarn com.ironsource.**
-keep class com.anythink.** { *; }
-dontwarn com.anythink.**
-keep class com.applovin.** { *; }
-dontwarn com.applovin.**

# Firebase ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# OkHttp / Retrofit / Gson / Moshi
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class com.squareup.moshi.** { *; }
-dontwarn com.squareup.moshi.**

# Glide / Picasso / Coil
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**
-keep class com.squareup.picasso.** { *; }
-dontwarn com.squareup.picasso.**
-keep class coil.** { *; }
-dontwarn coil.**

# Room / Lifecycle / Jetpack
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**
-keep class androidx.room.** { *; }
-dontwarn androidx.room.**

##################################################
## 通用反射安全
##################################################

# WebView JavaScript 接口
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 防止原生方法丢失
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保留枚举
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 日志、异常
-keep public class * extends java.lang.Exception

##################################################
## 忽略无害警告
##################################################
-dontwarn java.lang.invoke.**
-dontwarn org.slf4j.**
-dontwarn org.apache.log4j.**
-dontnote