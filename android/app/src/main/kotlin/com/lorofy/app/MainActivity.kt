package com.lorofy.app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.lorofy.app/foreground_app"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INTENT_ERROR", e.message, null)
                    }
                }
                "getForegroundApp" -> {
                    val packageName = getForegroundAppPackageName()
                    result.success(packageName)
                }
                "isLauncherApp" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg == null) {
                        result.success(false)
                    } else {
                        result.success(isLauncherPackage(pkg))
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getForegroundAppPackageName(): String? {
        if (!hasUsageStatsPermission()) {
            return null
        }
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return null

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 60000 // Look back 60 seconds

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        var lastResumedPackage: String? = null
        var lastTimeStamp: Long = 0

        while (usageEvents.hasNextEvent()) {
            val event = UsageEvents.Event()
            usageEvents.getNextEvent(event)
            if ((event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                 event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) &&
                event.timeStamp >= lastTimeStamp
            ) {
                lastTimeStamp = event.timeStamp
                lastResumedPackage = event.packageName
            }
        }

        return lastResumedPackage
    }

    private fun isLauncherPackage(pkg: String): Boolean {
        if (pkg == "com.android.systemui" || pkg.contains("launcher") || pkg.contains("home")) {
            return true
        }
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val resolveInfos = packageManager.queryIntentActivities(intent, 0)
        for (info in resolveInfos) {
            if (info.activityInfo.packageName == pkg) {
                return true
            }
        }
        return false
    }
}
