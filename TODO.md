# 🕋 Al-Qur'an Digital - Roadmap & Fitur TODO

Dokumen ini digunakan untuk melacak ide, rencana pengembangan, dan progres fitur-fitur baru pada aplikasi **Al-Qur'an Digital**.

---

## 📋 Daftar Rencana Pengembangan Fitur

### 1. 🔖 Sistem Bookmark & Favorit Ayat
Memungkinkan pengguna untuk menyimpan beberapa ayat pilihan dari berbagai surah ke dalam daftar favorit mereka untuk referensi cepat.
*   [x] Buat tabel SQLite baru `bookmarks` (kolom: `id`, `nomorSurah`, `namaSurah`, `nomorAyat`, `teksArab`, `teksIndonesia`, `createdAt`).
*   [x] Tambahkan tombol ikon Bookmark di samping tombol Copy/Share di setiap item ayat pada `DetailSurahView`.
*   [x] Buat modul baru `bookmarks` (Controller & View) untuk menampilkan daftar ayat yang disimpan.
*   [x] Tambahkan opsi untuk menghapus bookmark dari daftar.

### 2. 🔍 Pencarian Ayat Global (Teks & Terjemahan)
Mempermudah pengguna mencari ayat berdasarkan kata kunci tertentu secara cepat di seluruh Al-Qur'an.
*   [x] Tambahkan fitur pencarian teks di repositori lokal menggunakan query database SQLite `LIKE %query%`.
*   [x] Sediakan UI Pencarian di halaman utama atau tab pencarian khusus.
*   [x] Tampilkan hasil pencarian berupa daftar ayat lengkap dengan informasi Nama Surah & Nomor Ayat.
*   [x] Implementasikan pencarian untuk:
    *   [x] Terjemahan Bahasa Indonesia (misal: "sabar", "sholat").
    *   [x] Teks Latin/Transliterasi.

### 3. ⚙️ Pengaturan Notifikasi Adzan Kustom
Meningkatkan fleksibilitas dan personalisasi waktu sholat bagi masing-masing pengguna.
*   [x] Tambahkan halaman Pengaturan Jadwal Sholat/Adzan.
*   [x] **Mute per Waktu Sholat**:
    *   [x] Sakelar ON/OFF Adzan Subuh
    *   [x] Sakelar ON/OFF Adzan Dzuhur
    *   [x] Sakelar ON/OFF Adzan Ashar
    *   [x] Sakelar ON/OFF Adzan Maghrib
    *   [x] Sakelar ON/OFF Adzan Isya

### 4. 🕒 Pengingat Pra-Waktu Sholat (Sebelum Adzan)
Memberikan waktu persiapan wudhu sebelum masuknya waktu sholat utama.
*   [x] Tambahkan pengaturan opsi pengingat (misal: 10 menit atau 15 menit sebelum sholat).
*   [x] Jadwalkan alarm pengingat pra-sholat menggunakan `flutter_local_notifications`.

### 5. 📱 Widget Layar Utama (Home Screen Widget)
Menampilkan jadwal sholat hari ini di halaman depan ponsel pengguna.
*   [x] Integrasikan paket integrasi widget native seperti `home_widget` untuk Android & iOS.
*   [x] Desain widget dengan estetika modern, menampilkan waktu sholat terdekat dan hitung mundur.

### 6. 📝 Catatan Tafsir Pribadi & Tadabbur (Catatan Ayat)
Menyediakan wadah bagi pengguna untuk menulis refleksi atau catatan pribadi mengenai isi kandungan ayat tertentu.
*   [x] Buat tabel SQLite baru `notes` (kolom: `id`, `nomorSurah`, `namaSurah`, `nomorAyat`, `teksCatatan`, `updatedAt`).
*   [x] Tambahkan tombol ikon Catatan (Note) di samping tombol Bookmark pada setiap item ayat di `DetailSurahView`.
*   [x] Sediakan Bottom Sheet input catatan dan tampilkan badge indikator visual di ayat yang memiliki catatan.
*   [x] Integrasikan daftar Catatan ke dalam modul Bookmarks (dengan struktur 2 Tab: Bookmark & Catatan).

### 7. 🎛️ Media Kontrol Murottal di Bar Notifikasi (Background Player)
Mengintegrasikan pemutar audio Murottal dengan kontrol media sistem operasi native agar mudah dikendalikan dari lockscreen.
*   [ ] Integrasikan plugin audio background (seperti `just_audio` + `audio_service` atau setup background session `audioplayers`).
*   [ ] Tampilkan judul surah, qori, dan tombol Play/Pause/Stop/Seek di laci notifikasi dan lockscreen.

### 8. 🎯 Target & Pelacak Tilawah Harian (Daily Tilawah Tracker)
Membantu pengguna tetap konsisten dalam membaca Al-Quran dengan target harian dan sistem streak tilawah.
*   [ ] Buat tabel SQLite `tilawah_progress` (kolom: `id`, `tanggal`, `jumlahAyatDibaca`).
*   [ ] Tampilkan kartu ringkasan target harian dan streak tilawah (misal: "Tilawah 5 Hari Beruntun! 🔥") di Beranda.
*   [ ] Implementasikan penghitung ayat yang dibaca secara otomatis ketika membuka surah.
*   [ ] Sediakan visualisasi grafik progres 7 hari terakhir.

---

## 🛠️ Catatan & Panduan Teknis Pengembangan

> [!TIP]
> **Manajemen State GetX:**
> Gunakan GetX CLI untuk menginisialisasi modul baru secara bersih dengan perintah:
> `get create page:nama_fitur` jika GetX CLI terpasang, atau ikuti struktur modular yang ada pada `lib/app/modules/`.

> [!IMPORTANT]
> **Registrasi Aset Suara Adzan Baru:**
> Jika menambahkan file audio adzan baru ke dalam aset Android (`android/app/src/main/res/raw/`), pastikan untuk menaikkan versi ID channel notifikasi di `NotificationHelper` (contoh: dari `sholat_channel_v3` ke `sholat_channel_v4`) agar Android meregistrasi ulang file audio baru tersebut sebagai default ringtone channel.
