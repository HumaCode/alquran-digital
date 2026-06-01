# 🕋 Al-Qur'an Digital

Aplikasi Muslim companion yang komprehensif dan modern, dibangun dengan Flutter. Dirancang untuk membantu umat Muslim dalam menjalankan ibadah sehari-hari dengan tampilan premium, responsif di segala ukuran layar, dan berjalan penuh secara offline.

---

## ✨ Fitur Utama

### 📖 Al-Qur'an
- **Baca Al-Qur'an** — 114 Surah lengkap dengan teks Arab, transliterasi latin, dan terjemahan Bahasa Indonesia.
- **Bismillah Header** — Ditampilkan otomatis di setiap surah kecuali At-Taubah.
- **Bookmark Ayat** — Simpan ayat favorit secara offline ke database SQLite lokal dengan animasi interaktif.
- **Catatan Tadabbur** — Tulis, edit, dan hapus refleksi pribadi per ayat. Dilengkapi badge visual pada ayat yang memiliki catatan.
- **Export & Share Catatan** — Bagikan catatan tadabbur via WhatsApp (format teks siap kirim) atau ekspor semua catatan ke file `.txt`.
- **Mode Hafalan** — Sembunyikan kata Arab secara acak, fitur audio loop per ayat N kali, dan badge status hafalan dengan penyimpanan di tabel `hafalan_progress`.
- **Mode Baca Malam (Night Reader)** — Tampilan gelap pekat dengan teks emas redup untuk kenyamanan membaca di malam hari.
- **Pencarian Ayat Global & Lanjut** — Cari kata kunci di seluruh 6.236 ayat (terjemahan & latin), filter Makkiyah/Madaniyah, filter panjang surah, highlight kuning pada hasil cocok, dan riwayat 10 pencarian terakhir.
- **Tracker Khatam Al-Quran** — Tandai surah selesai, lihat progress "X dari 114 Surah", dan estimasi tanggal khatam otomatis.

### 🕌 Ibadah & Jadwal
- **Jadwal Sholat** — Waktu sholat 5 waktu akurat berbasis lokasi GPS/IP, dilengkapi countdown real-time dan tabel jadwal bulanan.
- **Jadwal Imsakiyah** — Jadwal imsak dan buka puasa lengkap sebulan penuh untuk panduan ibadah puasa.
- **Arah Kiblat** — Kompas digital presisi berbasis sensor akselerometer & magnetometer ponsel.
- **Notifikasi Adzan** — Alarm adzan otomatis untuk setiap waktu sholat dengan audio adzan kustom.
- **Mute Adzan per Waktu** — Sakelar ON/OFF granular per waktu sholat (Subuh, Dzuhur, Ashar, Maghrib, Isya).
- **Pengingat Pra-Adzan** — Alarm siap wudhu yang dapat dikonfigurasi (5–30 menit sebelum adzan).

### 🎧 Murotal
- **Pemutar Murotal** — Dengarkan murotal 114 surah lengkap dari 6 qori pilihan.
- **Background Player** — Pemutaran terus berjalan saat aplikasi diminimize, didukung media control di notifikasi & lockscreen.
- **Download Offline** — Unduh murotal surah untuk diputar tanpa koneksi internet.
- **Mode Pengulangan (Repeat)** — Repeat satu surah, surah dalam juz yang sama, atau seluruh Al-Quran.

### 📊 Statistik & Tracker
- **Daily Tilawah Tracker** — Lacak ayat yang dibaca per hari, hitung streak beruntun 🔥, dan visualisasi grafik 7 & 30 hari terakhir.
- **Target Tilawah Harian** — Atur target ayat harian kustom dari menu Pengaturan.
- **Reminder Tilawah** — Notifikasi pengingat terjadwal jika target hari itu belum terpenuhi.
- **Statistik Lengkap** — Total ayat sepanjang masa, rata-rata harian, streak terpanjang, dan sistem badge/achievement (Khatam Pertama 🏆, Streak 7 Hari 🔥, Baca 1000 Ayat ⭐, dll).

### 🏠 Widget & Pengaturan
- **Widget Layar Utama** — 3 widget native Android: Jadwal Sholat & Countdown Real-time, Ayat Harian Acak, dan Bar Progress Tilawah.
- **Tema Warna Kustom** — 4 palet warna premium: Emerald Green (default), Biru Safir, Ungu Amethyst, Coklat Tembaga. Disimpan permanen di database lokal dengan *Live Preview* interaktif.
- **Optimasi Baterai & Notifikasi** — Panel status dan panduan khusus per merek HP (Xiaomi, Samsung, Oppo, Vivo) untuk memastikan adzan tidak ditunda oleh sistem Doze Mode saat standby.
- **Mode Gelap / Terang** — Adaptif dengan preferensi tersimpan permanen.

---

## 📸 Cuplikan Layar (Screenshots)

<table>
  <tr>
    <td align="center">
      <b>Splash Screen</b><br>
      <img src="https://github.com/user-attachments/assets/249ea40a-edc5-45c5-896e-348635f30ba6" width="220">
    </td>
    <td align="center">
      <b>Beranda (Home)</b><br>
      <img src="https://github.com/user-attachments/assets/abb69885-1036-4d0b-a11c-379d791233b6" width="220">
    </td>
    <td align="center">
      <b>Sidebar Menu</b><br>
      <img src="https://github.com/user-attachments/assets/7a6d592b-1544-4726-85d0-1242bb872643" width="220">
    </td>
    <td align="center">
      <b>Halaman Doa</b><br>
      <img src="https://github.com/user-attachments/assets/da6f42e9-2bef-453d-8d26-81c451d0aa71" width="220">
    </td>
  </tr>
  <tr>
    <td align="center">
      <b>Jadwal Sholat</b><br>
      <img src="https://github.com/user-attachments/assets/49d93cb5-4727-40e4-b785-dc226e9b4c28" width="220">
    </td>
    <td align="center">
      <b>Imsakiyah</b><br>
      <img src="https://github.com/user-attachments/assets/709a0d10-9cfc-4f6a-9b00-aab449312180" width="220">
    </td>
    <td align="center">
      <b>Arah Kiblat</b><br>
      <img src="https://github.com/user-attachments/assets/b417bf33-fd7c-45f8-a72c-89ee2d33528f" width="220">
    </td>
    <td align="center">
      <b>Murotal</b><br>
      <img src="https://github.com/user-attachments/assets/cf3a9ede-7549-4e76-b80b-2e21df9ac6af" width="220">
    </td>
  </tr>
</table>

---

## 🛠️ Teknologi yang Digunakan

| Kategori | Teknologi |
|---|---|
| **Framework** | Flutter / Dart (SDK ^3.10.7) |
| **State Management** | GetX (`get: ^4.7.3`) |
| **Database Lokal** | SQLite via `sqflite: ^2.4.2+1` |
| **Responsivitas UI** | `flutter_screenutil: ^5.9.3` |
| **Audio Player** | `just_audio: ^0.9.38` + `just_audio_background` |
| **Notifikasi & Alarm** | `flutter_local_notifications: ^21.0.0` + `timezone` |
| **Widget Layar Utama** | `home_widget: ^0.9.2` (native Android AppWidget) |
| **Geolokasi** | `geolocator: ^14.0.2` |
| **Kompas** | `flutter_compass: ^0.8.1` |
| **Preferensi Lokal** | `shared_preferences: ^2.5.5` |
| **Share/Export** | `share_plus: ^12.0.2` |
| **Native Integration** | Kotlin MethodChannel (battery optimization) |

---

## 🗂️ Struktur Proyek

```
lib/
├── app/
│   ├── constants/        # Token warna, tipografi, string terpusat (R.color, R.string, R.textStyle)
│   ├── components/       # Widget reusable (CustomToast, dll.)
│   ├── data/
│   │   ├── models/       # Model data (Surah, Ayat, Jadwal Sholat, dll.)
│   │   ├── providers/    # DatabaseHelper, NotificationHelper, BatteryHelper, ThemeController
│   │   └── repositories/ # Abstraksi akses data (SurahRepository)
│   ├── modules/          # Modul fitur (home, detailSurah, murotal, jadwalSholat, dll.)
│   │   └── [modul]/
│   │       ├── bindings/
│   │       ├── controllers/
│   │       └── views/
│   └── routes/           # Definisi rute (AppPages, Routes, _Paths — lowerCamelCase)
├── main.dart
android/
├── app/src/main/
│   ├── kotlin/           # MainActivity.kt (MethodChannel battery optimization)
│   ├── res/raw/          # File audio adzan native
│   └── AndroidManifest.xml
```

---

## 🚀 Cara Menjalankan Proyek

1. **Clone repository:**
   ```bash
   git clone https://github.com/username/alquran_digital.git
   cd alquran_digital
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Jalankan di emulator atau perangkat fisik:**
   ```bash
   flutter run
   ```

4. **Build APK (opsional):**
   ```bash
   flutter build apk --release
   ```

> **Catatan:** Pastikan Android SDK telah terpasang dan emulator/perangkat sudah terhubung sebelum menjalankan proyek.

---

## 📝 Catatan Teknis

- **Versi minimum Android:** API 21 (Android 5.0 Lollipop)
- **Notifikasi Adzan Tepat Waktu:** Untuk memastikan alarm adzan tidak ditunda saat ponsel standby (*Doze Mode*), buka menu **Pengaturan → Optimasi Baterai & Notifikasi** dan ikuti panduan sesuai merek ponsel Anda.
- **Registrasi Channel Audio Baru:** Jika mengganti file audio adzan di `android/app/src/main/res/raw/`, naikkan versi ID channel di `NotificationHelper` (misal: dari `sholat_adzan_standard_v2` ke `v3`) agar Android meregistrasi ulang audio baru tersebut.

---

## 👤 Developer

Dikembangkan oleh **HumaCode** — Juni 2026
