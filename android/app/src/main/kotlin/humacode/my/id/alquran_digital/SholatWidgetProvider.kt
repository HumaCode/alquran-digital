package humacode.my.id.alquran_digital

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences

class SholatWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.sholat_widget)
            
            // Read from Shared Preferences (HomeWidgetPrefs, written by home_widget)
            val prefs = context.getSharedPreferences("HomeWidgetPrefs", Context.MODE_PRIVATE)
            
            val location = prefs.getString("location", "Kota Pekalongan")
            val nextPrayerName = prefs.getString("next_prayer_name", "-")
            val nextPrayerTime = prefs.getString("next_prayer_time", "--:--")
            
            // Dynamic countdown computed on render
            val countdown = calculateCountdown(nextPrayerTime)
            
            val subuh = prefs.getString("time_subuh", "--:--")
            val dzuhur = prefs.getString("time_dzuhur", "--:--")
            val ashar = prefs.getString("time_ashar", "--:--")
            val maghrib = prefs.getString("time_maghrib", "--:--")
            val isya = prefs.getString("time_isya", "--:--")
            
            // Update Views
            views.setTextViewText(R.id.widget_location, location)
            views.setTextViewText(R.id.widget_next_name, nextPrayerName)
            views.setTextViewText(R.id.widget_next_time, nextPrayerTime)
            views.setTextViewText(R.id.widget_countdown, countdown)
            
            views.setTextViewText(R.id.widget_time_subuh, subuh)
            views.setTextViewText(R.id.widget_time_dzuhur, dzuhur)
            views.setTextViewText(R.id.widget_time_ashar, ashar)
            views.setTextViewText(R.id.widget_time_maghrib, maghrib)
            views.setTextViewText(R.id.widget_time_isya, isya)
            
            // Tell the AppWidgetManager to perform an update on the current app widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun calculateCountdown(nextTime: String?): String {
        if (nextTime == null || nextTime == "--:--" || !nextTime.contains(":")) return ""
        try {
            val parts = nextTime.split(":")
            val targetHour = parts[0].toIntOrNull() ?: return ""
            val targetMin = parts[1].toIntOrNull() ?: return ""

            val now = java.util.Calendar.getInstance()
            val target = java.util.Calendar.getInstance().apply {
                set(java.util.Calendar.HOUR_OF_DAY, targetHour)
                set(java.util.Calendar.MINUTE, targetMin)
                set(java.util.Calendar.SECOND, 0)
                set(java.util.Calendar.MILLISECOND, 0)
            }

            if (target.before(now)) {
                target.add(java.util.Calendar.DATE, 1)
            }

            val diffMs = target.timeInMillis - now.timeInMillis
            val diffMins = (diffMs / (1000 * 60)).toInt()

            return if (diffMins > 60) {
                val hours = diffMins / 60
                val mins = diffMins % 60
                "$hours jam $mins mnt lagi"
            } else {
                "$diffMins mnt lagi"
            }
        } catch (e: Exception) {
            return ""
        }
    }
}
