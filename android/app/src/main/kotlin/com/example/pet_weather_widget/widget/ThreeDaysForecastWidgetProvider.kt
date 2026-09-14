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

                val location = widgetData.getString("weather_location", "내 위치") ?: "내 위치"
                setTextViewText(R.id.tv_three_location, "📍 $location")

                // Day 1: 오늘
                val d1Sub = widgetData.getString("day1_subdate", "") ?: ""
                val d1Icon = widgetData.getString("day1_icon", "☀️") ?: "☀️"
                val d1Temp = widgetData.getString("day1_temp", "--° / --°") ?: "--° / --°"
                val d1Rise = widgetData.getString("day1_sunrise", "06:00") ?: "06:00"
                val d1Set = widgetData.getString("day1_sunset", "18:00") ?: "18:00"
                setTextViewText(R.id.tv_day1_title, "오늘")
                if (d1Sub.isNotEmpty()) setTextViewText(R.id.tv_day1_subdate, d1Sub)
                setTextViewText(R.id.tv_day1_icon, d1Icon)
                setTextViewText(R.id.tv_day1_temp, d1Temp)
                setTextViewText(R.id.tv_day1_sun, "🌅 $d1Rise  /  🌇 $d1Set")

                // Day 2: 내일
                val d2Sub = widgetData.getString("day2_subdate", "") ?: ""
                val d2Icon = widgetData.getString("day2_icon", "⛅") ?: "⛅"
                val d2Temp = widgetData.getString("day2_temp", "--° / --°") ?: "--° / --°"
                val d2Rise = widgetData.getString("day2_sunrise", "06:00") ?: "06:00"
                val d2Set = widgetData.getString("day2_sunset", "18:00") ?: "18:00"
                setTextViewText(R.id.tv_day2_title, "내일")
                if (d2Sub.isNotEmpty()) setTextViewText(R.id.tv_day2_subdate, d2Sub)
                setTextViewText(R.id.tv_day2_icon, d2Icon)
                setTextViewText(R.id.tv_day2_temp, d2Temp)
                setTextViewText(R.id.tv_day2_sun, "🌅 $d2Rise  /  🌇 $d2Set")

                // Day 3: 모레
                val d3Sub = widgetData.getString("day3_subdate", "") ?: ""
                val d3Icon = widgetData.getString("day3_icon", "🌧️") ?: "🌧️"
                val d3Temp = widgetData.getString("day3_temp", "--° / --°") ?: "--° / --°"
                val d3Rise = widgetData.getString("day3_sunrise", "06:00") ?: "06:00"
                val d3Set = widgetData.getString("day3_sunset", "18:00") ?: "18:00"
                setTextViewText(R.id.tv_day3_title, "모레")
                if (d3Sub.isNotEmpty()) setTextViewText(R.id.tv_day3_subdate, d3Sub)
                setTextViewText(R.id.tv_day3_icon, d3Icon)
                setTextViewText(R.id.tv_day3_temp, d3Temp)
                setTextViewText(R.id.tv_day3_sun, "🌅 $d3Rise  /  🌇 $d3Set")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}