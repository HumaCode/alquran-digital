package humacode.my.id.alquran_digital

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

import es.antonborri.home_widget.HomeWidgetPlugin

class ProgressWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.progress_widget)
            val prefs = HomeWidgetPlugin.getData(context)
            
            val today = prefs.getInt("tilawah_today", 0)
            val target = prefs.getInt("tilawah_target", 10)
            val streak = prefs.getInt("tilawah_streak", 0)
            
            val progressPercent = if (target > 0) (today * 100) / target else 0
            
            views.setTextViewText(R.id.widget_streak, "🔥 $streak Hari Streak")
            views.setTextViewText(R.id.widget_progress_text, "$today dari $target ayat")
            views.setTextViewText(R.id.widget_progress_percent, "$progressPercent%")
            
            views.setProgressBar(R.id.widget_progress_bar, 100, progressPercent, false)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
