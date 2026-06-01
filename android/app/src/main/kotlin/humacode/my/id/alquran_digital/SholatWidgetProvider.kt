package humacode.my.id.alquran_digital

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.graphics.Color
import android.os.Build
import java.util.Calendar
import es.antonborri.home_widget.HomeWidgetPlugin

class SholatWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        var alarmTargetMs = 0L
        val now = Calendar.getInstance()
        val nowTime = now.timeInMillis

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.sholat_widget)
            
            // Membaca data SharedPreferences via HomeWidgetPlugin
            val prefs = HomeWidgetPlugin.getData(context)
            
            val location = prefs.getString("location", "Kota Pekalongan")
            
            val subuh = prefs.getString("time_subuh", "--:--")
            val dzuhur = prefs.getString("time_dzuhur", "--:--")
            val ashar = prefs.getString("time_ashar", "--:--")
            val maghrib = prefs.getString("time_maghrib", "--:--")
            val isya = prefs.getString("time_isya", "--:--")
            
            // Set teks jadwal sholat dasar
            views.setTextViewText(R.id.widget_location, location)
            views.setTextViewText(R.id.widget_gregorian_date, getGregorianDate())
            views.setTextViewText(R.id.widget_hijri_date, getHijriDate())
            views.setTextViewText(R.id.widget_time_subuh, subuh)
            views.setTextViewText(R.id.widget_time_dzuhur, dzuhur)
            views.setTextViewText(R.id.widget_time_ashar, ashar)
            views.setTextViewText(R.id.widget_time_maghrib, maghrib)
            views.setTextViewText(R.id.widget_time_isya, isya)
            
            val prayers = listOf(
                Pair("Subuh", subuh),
                Pair("Dzuhur", dzuhur),
                Pair("Ashar", ashar),
                Pair("Maghrib", maghrib),
                Pair("Isya", isya)
            )
            
            var activePrayerName = ""
            var activePrayerTime = ""
            var activePrayerTargetMs = 0L
            var isOngoingState = false
            
            // 1. Cek apakah saat ini sedang dalam 10 menit pertama waktu sholat berjalan
            for (p in prayers) {
                val cal = getPrayerCalendar(p.second) ?: continue
                val calTime = cal.timeInMillis
                val tenMinsAfterTime = calTime + 600000 // 10 menit = 600.000 ms
                
                if (nowTime in calTime until tenMinsAfterTime) {
                    isOngoingState = true
                    activePrayerName = p.first
                    activePrayerTime = p.second ?: "--:--"
                    activePrayerTargetMs = tenMinsAfterTime
                    break
                }
            }
            
            var highlightPrayer = ""
            var targetMs = 0L
            
            if (isOngoingState) {
                views.setTextViewText(R.id.widget_next_label, "Masuk Waktu")
                views.setTextViewText(R.id.widget_next_name, activePrayerName)
                views.setTextViewText(R.id.widget_next_time, "Laksanakan Sholat")
                targetMs = activePrayerTargetMs
                highlightPrayer = activePrayerName
            } else {
                // 2. Cari sholat berikutnya jika tidak ada sholat yang sedang berlangsung
                var nextPrayerName = "-"
                var nextPrayerTime = "--:--"
                
                for (p in prayers) {
                    val cal = getPrayerCalendar(p.second) ?: continue
                    if (cal.timeInMillis > nowTime) {
                        nextPrayerName = p.first
                        nextPrayerTime = p.second ?: "--:--"
                        targetMs = cal.timeInMillis
                        break
                    }
                }
                
                // Jika semua sholat hari ini sudah terlewati, maka sholat berikutnya adalah Subuh esok
                if (nextPrayerName == "-") {
                    nextPrayerName = "Subuh"
                    nextPrayerTime = subuh ?: "--:--"
                    val subuhTomorrow = getPrayerCalendar(subuh, isTomorrow = true)
                    if (subuhTomorrow != null) {
                        targetMs = subuhTomorrow.timeInMillis
                    }
                }
                
                views.setTextViewText(R.id.widget_next_label, "Sholat Berikutnya")
                views.setTextViewText(R.id.widget_next_name, nextPrayerName)
                views.setTextViewText(R.id.widget_next_time, nextPrayerTime)
                
                // Tentukan periode waktu sholat mana yang saat ini sedang aktif untuk di-highlight
                val subuhCal = getPrayerCalendar(subuh)
                val dzuhurCal = getPrayerCalendar(dzuhur)
                val asharCal = getPrayerCalendar(ashar)
                val maghribCal = getPrayerCalendar(maghrib)
                val isyaCal = getPrayerCalendar(isya)
                
                val subuhTime = subuhCal?.timeInMillis ?: 0L
                val dzuhurTime = dzuhurCal?.timeInMillis ?: 0L
                val asharTime = asharCal?.timeInMillis ?: 0L
                val maghribTime = maghribCal?.timeInMillis ?: 0L
                val isyaTime = isyaCal?.timeInMillis ?: 0L
                
                highlightPrayer = if (subuhTime > 0L && nowTime < subuhTime) {
                    "Isya"
                } else if (subuhTime > 0L && dzuhurTime > 0L && nowTime >= subuhTime && nowTime < dzuhurTime) {
                    "Subuh"
                } else if (dzuhurTime > 0L && asharTime > 0L && nowTime >= dzuhurTime && nowTime < asharTime) {
                    "Dzuhur"
                } else if (asharTime > 0L && maghribTime > 0L && nowTime >= asharTime && nowTime < maghribTime) {
                    "Ashar"
                } else if (maghribTime > 0L && isyaTime > 0L && nowTime >= maghribTime && nowTime < isyaTime) {
                    "Maghrib"
                } else {
                    "Isya"
                }
            }
            
            // Simpan targetMs untuk alarm pembaruan otomatis
            if (targetMs > 0L) {
                alarmTargetMs = targetMs
            }
            
            // 3. Konfigurasi Chronometer untuk hitung mundur secara real-time
            if (targetMs > 0L) {
                val timeDifference = targetMs - System.currentTimeMillis()
                val chronometerBase = android.os.SystemClock.elapsedRealtime() + timeDifference
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    views.setChronometerCountDown(R.id.widget_countdown, true)
                }
                views.setChronometer(R.id.widget_countdown, chronometerBase, "%s lagi", true)
            }
            
            // 4. Bersihkan/Reset desain item sholat pada footer
            val itemIds = intArrayOf(
                R.id.widget_item_subuh,
                R.id.widget_item_dzuhur,
                R.id.widget_item_ashar,
                R.id.widget_item_maghrib,
                R.id.widget_item_isya
            )
            val labelIds = intArrayOf(
                R.id.widget_label_subuh,
                R.id.widget_label_dzuhur,
                R.id.widget_label_ashar,
                R.id.widget_label_maghrib,
                R.id.widget_label_isya
            )
            val timeIds = intArrayOf(
                R.id.widget_time_subuh,
                R.id.widget_time_dzuhur,
                R.id.widget_time_ashar,
                R.id.widget_time_maghrib,
                R.id.widget_time_isya
            )
            
            for (i in 0..4) {
                views.setInt(itemIds[i], "setBackgroundResource", 0)
                views.setTextColor(labelIds[i], Color.parseColor("#8DA09C"))
                views.setTextColor(timeIds[i], Color.parseColor("#FFFFFF"))
            }
            
            // 5. Beri highlight pill card pada sholat yang sedang aktif
            val activeIdx = when (highlightPrayer) {
                "Subuh" -> 0
                "Dzuhur" -> 1
                "Ashar" -> 2
                "Maghrib" -> 3
                "Isya" -> 4
                else -> -1
            }
            
            if (activeIdx != -1) {
                views.setInt(itemIds[activeIdx], "setBackgroundResource", R.drawable.active_prayer_background)
                views.setTextColor(labelIds[activeIdx], Color.parseColor("#2EC4B6"))
                views.setTextColor(timeIds[activeIdx], Color.parseColor("#E6C485"))
            }
            
            // Tombol judul diklik untuk refresh widget secara manual
            val refreshIntent = android.content.Intent(context, SholatWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            }
            val pendingIntent = android.app.PendingIntent.getBroadcast(
                context,
                appWidgetId,
                refreshIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        // Jadwalkan pembaruan widget otomatis pada targetMs
        if (alarmTargetMs > 0L) {
            scheduleWidgetUpdate(context, alarmTargetMs)
        }
    }

    private fun scheduleWidgetUpdate(context: Context, timeMs: Long) {
        if (timeMs <= System.currentTimeMillis()) return
        
        val intent = Intent(context, SholatWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, SholatWidgetProvider::class.java)
            )
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            999, // Request code unik untuk pembaruan terjadwal
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeMs, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, timeMs, pendingIntent)
            }
        } catch (e: Exception) {
            alarmManager.set(AlarmManager.RTC_WAKEUP, timeMs, pendingIntent)
        }
    }

    private fun getPrayerCalendar(timeStr: String?, isTomorrow: Boolean = false): Calendar? {
        if (timeStr == null || timeStr == "--:--" || !timeStr.contains(":")) return null
        try {
            val parts = timeStr.trim().split(":")
            val hour = parts[0].toInt()
            val min = parts[1].toInt()
            val cal = Calendar.getInstance()
            cal.set(Calendar.HOUR_OF_DAY, hour)
            cal.set(Calendar.MINUTE, min)
            cal.set(Calendar.SECOND, 0)
            cal.set(Calendar.MILLISECOND, 0)
            if (isTomorrow) {
                cal.add(Calendar.DATE, 1)
            }
            return cal
        } catch (e: Exception) {
            return null
        }
    }

    private fun getGregorianDate(): String {
        val cal = Calendar.getInstance()
        val dayOfWeek = when (cal.get(Calendar.DAY_OF_WEEK)) {
            Calendar.SUNDAY -> "Minggu"
            Calendar.MONDAY -> "Senin"
            Calendar.TUESDAY -> "Selasa"
            Calendar.WEDNESDAY -> "Rabu"
            Calendar.THURSDAY -> "Kamis"
            Calendar.FRIDAY -> "Jumat"
            Calendar.SATURDAY -> "Sabtu"
            else -> ""
        }
        val dayOfMonth = cal.get(Calendar.DAY_OF_MONTH)
        val month = when (cal.get(Calendar.MONTH)) {
            Calendar.JANUARY -> "Januari"
            Calendar.FEBRUARY -> "Februari"
            Calendar.MARCH -> "Maret"
            Calendar.APRIL -> "April"
            Calendar.MAY -> "Mei"
            Calendar.JUNE -> "Juni"
            Calendar.JULY -> "Juli"
            Calendar.AUGUST -> "Agustus"
            Calendar.SEPTEMBER -> "September"
            Calendar.OCTOBER -> "Oktober"
            Calendar.NOVEMBER -> "November"
            Calendar.DECEMBER -> "Desember"
            else -> ""
        }
        val year = cal.get(Calendar.YEAR)
        return "$dayOfWeek, $dayOfMonth $month $year"
    }

    private fun getHijriDate(): String {
        val cal = Calendar.getInstance()
        val year = cal.get(Calendar.YEAR)
        val month = cal.get(Calendar.MONTH) + 1
        val day = cal.get(Calendar.DAY_OF_MONTH)
        
        var y = year
        var m = month
        if (m <= 2) {
            y--
            m += 12
        }
        val a = y / 100
        val b = 2 - a + (a / 4)
        val jd = (365.25 * (y + 4716)).toInt() + (30.6001 * (m + 1)).toInt() + day + b - 1524
        
        val l = jd - 1948440 + 10632
        val n = (l - 1) / 10631
        val ll = l - 10631 * n + 354
        val j = ((10985 - ll) / 5316) * ((50 * ll) / 17719) + (ll / 5670) * ((43 * ll) / 15238)
        val lll = ll - ((30 - j) / 15) * ((17719 * j) / 50) - (j / 16) * ((15238 * j) / 43) + 29
        val hm = (24 * lll) / 709
        val hd = lll - (709 * hm) / 24
        val hy = 30 * n + j - 30
        
        val hijriMonths = listOf(
            "Muharram", "Shafar", "Rabiul Awal", "Rabiul Akhir",
            "Jumadal Ula", "Jumadal Akhirah", "Rajab", "Syakban",
            "Ramadhan", "Syawal", "Dzulqadah", "Dzulhijjah"
        )
        val hmName = if (hm in 1..12) hijriMonths[hm - 1] else ""
        return "$hd $hmName $hy H"
    }
}
