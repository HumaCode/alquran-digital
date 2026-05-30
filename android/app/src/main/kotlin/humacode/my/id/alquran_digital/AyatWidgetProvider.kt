package humacode.my.id.alquran_digital

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class AyatWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.ayat_widget)
            val prefs = context.getSharedPreferences("HomeWidgetPrefs", Context.MODE_PRIVATE)
            
            val arab = prefs.getString("ayat_arab", "كُتِبَ عَلَيْكُمُ الصِّيَامُ")
            val indo = prefs.getString("ayat_indo", "Diwajibkan atas kamu berpuasa...")
            val ref = prefs.getString("ayat_ref", "QS. Al-Baqarah: 183")
            
            views.setTextViewText(R.id.widget_ayat_arab, arab)
            views.setTextViewText(R.id.widget_ayat_indo, indo)
            views.setTextViewText(R.id.widget_ayat_ref, ref)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
