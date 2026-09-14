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

class WeatherSunWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_weather_sun_layout).apply {
                // Open App on Click
                val pendingIntent = Intent(context, MainActivity::class.java).let { intent ->
                    PendingIntent.getActivity(
                        context,
                        0,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                }
                setOnClickPendingIntent(R.id.widget_container_weather, pendingIntent)

                // Load cached widget data
                val location = widgetData.getString("weather_location", "서울시 중구")
                val temp = widgetData.getString("weather_temp", "24°C")
                val condition = widgetData.getString("weather_condition", "맑음 ☀️")
                val sunrise = widgetData.getString("sun_sunrise", "06:12")
                val sunset = widgetData.getString("sun_sunset", "18:48")
                val dateStr = widgetData.getString("widget_date", "오늘")

                setTextViewText(R.id.tv_widget_location, location)
                setTextViewText(R.id.tv_widget_temp, temp)
                setTextViewText(R.id.tv_widget_condition, condition)
                setTextViewText(R.id.tv_widget_sunrise, "일출 $sunrise")
                setTextViewText(R.id.tv_widget_sunset, "일몰 $sunset")
                setTextViewText(R.id.tv_widget_date, dateStr)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
