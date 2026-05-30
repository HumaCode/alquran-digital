# 🕋 Al-Qur'an Digital - Roadmap & Fitur TODO

Dokumen ini digunakan untuk melacak ide, rencana pengembangan, dan progres fitur-fitur baru pada aplikasi **Al-Qur'an Digital**.

---

## 📋 Daftar Rencana Pengembangan Fitur

### 1. 🔖 Sistem Bookmark & Favorit Ayat
Memungkinkan pengguna untuk menyimpan beberapa ayat pilihan dari berbagai surah ke dalam daftar favorit mereka untuk referensi cepat.
*   [ ] Buat tabel SQLite baru `bookmarks` (kolom: `id`, `nomorSurah`, `namaSurah`, `nomorAyat`, `teksArab`, `teksIndonesia`, `createdAt`).
*   [ ] Tambahkan tombol ikon Bookmark di samping tombol Copy/Share di setiap item ayat pada `DetailSurahView`.
*   [ ] Buat modul baru `bookmarks` (Controller & View) untuk menampilkan daftar ayat yang disimpan.
*   [ ] Tambahkan opsi untuk menghapus bookmark dari daftar.

### 2. 🔍 Pencarian Ayat Global (Teks & Terjemahan)
Mempermudah pengguna mencari ayat berdasarkan kata kunci tertentu secara cepat di seluruh Al-Qur'an.
*   [ ] Tambahkan fitur pencarian teks di repositori lokal menggunakan query database SQLite `LIKE %query%`.
*   [ ] Sediakan UI Pencarian di halaman utama atau tab pencarian khusus.
*   [ ] Tampilkan hasil pencarian berupa daftar ayat lengkap dengan informasi Nama Surah & Nomor Ayat.
*   [ ] Implementasikan pencarian untuk:
    *   [ ] Terjemahan Bahasa Indonesia (misal: "sabar", "sholat").
    *   [ ] Teks Latin/Transliterasi.

### 3. ⚙️ Pengaturan Notifikasi Adzan Kustom
Meningkatkan fleksibilitas dan personalisasi waktu sholat bagi masing-masing pengguna.
*   [ ] Tambahkan halaman Pengaturan Jadwal Sholat/Adzan.
*   [ ] **Pilihan Suara Adzan**:
    *   [ ] Adzan Makkah
    *   [ ] Adzan Madinah
    *   [ ] Adzan Mesir
    *   [ ] Beep/Notifikasi Standar
*   [ ] **Mute per Waktu Sholat**:
    *   [ ] Sakelar ON/OFF Adzan Subuh
    *   [ ] Sakelar ON/OFF Adzan Dzuhur
    *   [ ] Sakelar ON/OFF Adzan Ashar
    *   [ ] Sakelar ON/OFF Adzan Maghrib
    *   [ ] Sakelar ON/OFF Adzan Isya

### 4. 🕒 Pengingat Pra-Waktu Sholat (Sebelum Adzan)
Memberikan waktu persiapan wudhu sebelum masuknya waktu sholat utama.
*   [ ] Tambahkan pengaturan opsi pengingat (misal: 10 menit atau 15 menit sebelum sholat).
*   [ ] Jadwalkan alarm pengingat pra-sholat menggunakan `flutter_local_notifications`.

### 5. 📱 Widget Layar Utama (Home Screen Widget)
Menampilkan jadwal sholat hari ini di halaman depan ponsel pengguna.
*   [ ] Integrasikan paket integrasi widget native seperti `home_widget` untuk Android & iOS.
*   [ ] Desain widget dengan estetika modern, menampilkan waktu sholat terdekat dan hitung mundur.

---

## 🛠️ Catatan & Panduan Teknis Pengembangan

> [!TIP]
> **Manajemen State GetX:**
> Gunakan GetX CLI untuk menginisialisasi modul baru secara bersih dengan perintah:
> `get create page:nama_fitur` jika GetX CLI terpasang, atau ikuti struktur modular yang ada pada `lib/app/modules/`.

> [!IMPORTANT]
> **Registrasi Aset Suara Adzan Baru:**
> Jika menambahkan file audio adzan baru ke dalam aset Android (`android/app/src/main/res/raw/`), pastikan untuk menaikkan versi ID channel notifikasi di `NotificationHelper` (contoh: dari `sholat_channel_v3` ke `sholat_channel_v4`) agar Android meregistrasi ulang file audio baru tersebut sebagai default ringtone channel.
