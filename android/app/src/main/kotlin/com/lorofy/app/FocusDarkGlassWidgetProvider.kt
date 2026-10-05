package com.lorofy.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.widget.RemoteViews
import java.util.Locale

class FocusDarkGlassWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, FocusDarkGlassWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefsGroup = context.getSharedPreferences("group.com.lorofy.app", Context.MODE_PRIVATE)
        val prefsDefault = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        val widgetState = prefsGroup.getString("widget_state", null)
            ?: prefsDefault.getString("widget_state", "idle")
            ?: "idle"

        val statusText = prefsGroup.getString("status_text", null)
            ?: prefsDefault.getString("status_text", "Sẵn sàng Focus 🎯")
            ?: "Sẵn sàng Focus 🎯"

        val targetEndTimestamp = if (prefsGroup.contains("target_end_timestamp")) {
            prefsGroup.getLong("target_end_timestamp", 0L)
        } else {
            prefsDefault.getLong("target_end_timestamp", 0L)
        }

        val remainingSeconds = if (prefsGroup.contains("remaining_seconds")) {
            prefsGroup.getInt("remaining_seconds", 1500)
        } else {
            prefsDefault.getInt("remaining_seconds", 1500)
        }

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_focus_dark_glass)
            val now = System.currentTimeMillis()

            views.setTextViewText(R.id.widget_status_text, statusText)

            when (widgetState) {
                "running", "break" -> {
                    if (targetEndTimestamp > now) {
                        val remainingMillis = targetEndTimestamp - now
                        val baseTime = SystemClock.elapsedRealtime() + remainingMillis
                        views.setChronometer(R.id.widget_chronometer, baseTime, null, true)
                        views.setChronometerCountDown(R.id.widget_chronometer, true)
                    } else {
                        views.setChronometer(R.id.widget_chronometer, SystemClock.elapsedRealtime(), null, false)
                        views.setTextViewText(R.id.widget_chronometer, "00:00")
                    }
                    views.setImageViewResource(R.id.widget_btn_play_pause, R.drawable.ic_pause_white)
                }

                "paused" -> {
                    views.setChronometer(R.id.widget_chronometer, SystemClock.elapsedRealtime(), null, false)
                    val safeSecs = remainingSeconds.coerceAtLeast(0)
                    val mins = safeSecs / 60
                    val secs = safeSecs % 60
                    val timeStr = String.format(Locale.getDefault(), "%02d:%02d", mins, secs)
                    views.setTextViewText(R.id.widget_chronometer, timeStr)
                    views.setImageViewResource(R.id.widget_btn_play_pause, R.drawable.ic_play_white)
                }

                "completed" -> {
                    views.setChronometer(R.id.widget_chronometer, SystemClock.elapsedRealtime(), null, false)
                    views.setTextViewText(R.id.widget_chronometer, "00:00")
                    views.setImageViewResource(R.id.widget_btn_play_pause, R.drawable.ic_play_white)
                }

                else -> { // "idle"
                    views.setChronometer(R.id.widget_chronometer, SystemClock.elapsedRealtime(), null, false)
                    val safeSecs = remainingSeconds.coerceAtLeast(0)
                    val mins = safeSecs / 60
                    val secs = safeSecs % 60
                    val timeStr = String.format(Locale.getDefault(), "%02d:%02d", mins, secs)
                    views.setTextViewText(R.id.widget_chronometer, timeStr)
                    views.setImageViewResource(R.id.widget_btn_play_pause, R.drawable.ic_play_white)
                }
            }

            // Click action to open Lorofy app
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_dark_container, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_btn_stop, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_btn_play_pause, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
