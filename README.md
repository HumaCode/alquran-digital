# 🌙 Aplikasi Muslim Companion (Ganti dengan Nama Aplikasimu)

Aplikasi mobile komprehensif yang dirancang untuk membantu umat Muslim dalam menjalankan ibadah sehari-hari. Aplikasi ini dilengkapi dengan berbagai fitur esensial seperti Jadwal Sholat, Arah Kiblat, Kumpulan Doa, Jadwal Imsakiyah, dan pemutar audio Murottal.

## ✨ Fitur Utama

* **Beranda & Navigasi**: Tampilan antarmuka yang ramah pengguna dengan *Sidebar* untuk navigasi menu yang mudah.
* **Kumpulan Doa**: Menyediakan daftar doa-doa harian lengkap.
* **Jadwal Sholat**: Informasi waktu sholat yang akurat berdasarkan lokasi pengguna.
* **Jadwal Imsakiyah**: Jadwal imsak dan buka puasa untuk panduan ibadah puasa.
* **Arah Kiblat**: Kompas penunjuk arah kiblat yang presisi.
* **Murottal**: Fitur pemutar audio Al-Quran (Murottal).
* **Bookmark Ayat Al-Quran**: Menyimpan ayat favorit secara offline ke database SQLite lokal dengan tombol interaktif dan animasi getar gelombang yang halus saat dihapus.
* **Pencarian Ayat Global & Lanjut (Advanced Search)**: Mencari kata kunci tertentu di seluruh Al-Quran (transliterasi latin & terjemahan Indonesia) lengkap dengan highlight kuning pada kata yang cocok. Ditambah dengan pencarian lanjut yang menyaring surah berdasarkan Makkiyah/Madaniyah, panjang surah (pendek, sedang, panjang), highlight dinamis, dan riwayat 10 pencarian terakhir.
* **Pengaturan Adzan Kustom**: Fleksibilitas untuk menyalakan/mematikan (mute) suara adzan per waktu sholat (Subuh, Dzuhur, Ashar, Maghrib, Isya) secara granular.
* **Pengingat Sebelum Adzan**: Opsi alarm pengingat bersiap wudhu (5-30 menit sebelum adzan) menggunakan notifikasi lokal.
* **Widget Layar Utama Diperluas (Expanded Home Widgets)**: Tiga widget native Android (Jadwal Sholat & Countdown Real-time, Ayat Harian Acak, dan Bar Progress Tilawah & Streak) yang mempercantik layar utama HP secara instan.
* **Catatan Tafsir Pribadi & Tadabbur**: Menulis, mengedit, dan menghapus refleksi pribadi (tadabbur) per ayat secara offline. Lengkap dengan fitur **Ekspor ke File .txt** dan **Share WhatsApp** terformat siap kirim.
* **Murottal Background Player**: Pemutaran audio murottal terus berjalan lancar di latar belakang (background) didukung dengan bar notifikasi media control dan lockscreen widget native OS.
* **Target & Pelacak Tilawah Harian (Daily Tilawah Tracker)**: Melacak jumlah ayat yang dibaca per hari secara otomatis saat membuka surah, menghitung coretan streak tilawah beruntun, serta menyajikan visualisasi grafik progres 7 hari terakhir.
* **Tracker Khatam Al-Quran**: Melacak surah yang selesai dibaca (tabel `surah_read_history`), menampilkan progress global di Beranda ("X dari 114 Surah selesai"), estimasi tanggal khatam otomatis berdasarkan tilawah harian, dan tombol penyelesaian surah di Detail Surah.
* **Mode Hafalan (Memorization Mode)**: Membantu pengguna menghafal Al-Quran secara sistematis dengan menyembunyikan kata Arab secara acak, fitur audio loop per ayat sebanyak N kali, badge penanda status hafalan, dan penyimpanan progress di database `hafalan_progress`.
* **Tema Warna Kustom**: Pilihan 4 palet warna premium (Emerald Green, Biru Safir, Ungu Amethyst, Coklat Tembaga) dengan mode gelap/terang adaptif, disimpan permanen di database lokal, dan dilengkapi area *Live Preview* interaktif di halaman Pengaturan terpusat.

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

## 🛠️ Teknologi yang Digunakan

* **Framework:** Flutter / Dart
* **State Management:** GetX
* **Database Lokal:** SQLite (via `sqflite`)
* **Notifikasi & Alarm:** `flutter_local_notifications` & `timezone`
* **Widget Layar Utama:** `home_widget` (integrasi native Android AppWidget)
* **Audio Player:** `just_audio` & `just_audio_background` (sebelumnya `audioplayers`)

## 🚀 Cara Menjalankan Proyek (Getting Started)

Jika Anda ingin menjalankan proyek ini secara lokal, ikuti langkah-langkah berikut:

1. Clone repository ini:
   ```bash
   git clone [https://github.com/username-kamu/nama-repo-kamu.git](https://github.com/username-kamu/nama-repo-kamu.git)
