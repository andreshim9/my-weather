package com.example.pet_weather_widget.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.example.pet_weather_widget.MainActivity
import com.example.pet_weather_widget.R
import es.antonborri.home_widget.HomeWidgetProvider

class WalkGoldenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_walk_golden_layout).apply {
                val pendingIntent = Intent(context, MainActivity::class.java).let { intent ->
                    PendingIntent.getActivity(
                        context,
                        0,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                }
                setOnClickPendingIntent(R.id.widget_container_walk, pendingIntent)

                val location = widgetData.getString("weather_location", "내 위치")
                val temp = widgetData.getString("weather_temp", "24°C")
                val condition = widgetData.getString("weather_condition", "맑음 ☀️")
                val sunrise = widgetData.getString("sun_sunrise", "06:12")
                val sunset = widgetData.getString("sun_sunset", "18:48")
                val noon = widgetData.getString("sun_noon", "12:30")
                val dayLength = widgetData.getString("sun_day_length", "12시간 36분")

                setTextViewText(R.id.tv_walk_location, location)
                setTextViewText(R.id.tv_walk_temp, "$temp  $condition")
                setTextViewText(R.id.tv_walk_sunrise, sunrise)
                setTextViewText(R.id.tv_walk_sunset, sunset)
                setTextViewText(R.id.tv_walk_noon, noon)
                setTextViewText(R.id.tv_walk_day_length, "☀️ 낮의 총 길이: $dayLength")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
