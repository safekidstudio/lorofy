# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.app.FlutterPluginRegistry { *; }
-dontwarn io.flutter.embedding.**

# Keep Rive classes and native bindings
-keep class app.rive.** { *; }
-keep class com.rive.** { *; }
-dontwarn app.rive.**

# Keep AudioPlayers & AndroidX Media
-keep class com.solido.audioplayers.** { *; }
-dontwarn com.solido.audioplayers.**

# Keep Gson / Dio / Serializer classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Preserve Line Numbers for Crashlytics stack traces
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable,Signature,*Annotation*
