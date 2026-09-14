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

class ThreeDaysForecastWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_three_days_layout).apply {
                val pendingIntent = Intent(context, MainActivity::class.java).let { intent ->
                    PendingIntent.getActivity(
                        context,
                        0,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                }
                setOnClickPendingIntent(R.id.widget_container_three_days, pendingIntent)

                val location = widgetData.getString("weather_location", "내 위치")
                val temp = widgetData.getString("weather_temp", "24°C")
                val condition = widgetData.getString("weather_condition", "맑음 ☀️")
                val sunrise = widgetData.getString("sun_sunrise", "06:12")
                val sunset = widgetData.getString("sun_sunset", "18:48")
                val noon = widgetData.getString("sun_noon", "12:30")
                val dayLength = widgetData.getString("sun_day_length", "12시간 36분")

                setTextViewText(R.id.tv_three_location, location)
                setTextViewText(R.id.tv_three_temp, "$temp  $condition")
                setTextViewText(R.id.tv_three_sunrise, sunrise)
                setTextViewText(R.id.tv_three_sunset, sunset)
                setTextViewText(R.id.tv_three_noon, noon)
                setTextViewText(R.id.tv_three_day_length, "☀️ 낮의 총 길이: $dayLength")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
