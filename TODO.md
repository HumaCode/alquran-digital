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
*   [x] Integrasikan plugin audio background (seperti `just_audio` + `audio_service` atau setup background session `audioplayers`).
*   [x] Tampilkan judul surah, qori, dan tombol Play/Pause/Stop/Seek di laci notifikasi dan lockscreen.

### 8. 🎯 Target & Pelacak Tilawah Harian (Daily Tilawah Tracker)
Membantu pengguna tetap konsisten dalam membaca Al-Quran dengan target harian dan sistem streak tilawah.
*   [x] Buat tabel SQLite `tilawah_progress` (kolom: `id`, `tanggal`, `jumlahAyatDibaca`).
*   [x] Tampilkan kartu ringkasan target harian dan streak tilawah (misal: "Tilawah 5 Hari Beruntun! 🔥") di Beranda.
*   [x] Implementasikan penghitung ayat yang dibaca secara otomatis ketika membuka surah.
*   [x] Sediakan visualisasi grafik progres 7 hari terakhir.


---

## 🚀 Backlog Fitur Berikutnya

### Sprint 1 — Prioritas Tinggi (Dampak Langsung ke Pengguna)

#### 9. 🔔 Reminder Tilawah Harian
Mengingatkan pengguna jika target tilawah harian belum tercapai di penghujung hari.
*   [x] Jadwalkan notifikasi lokal terjadwal (misal: jam 20:00) menggunakan `flutter_local_notifications` yang sudah ada.
*   [x] Notifikasi hanya muncul jika target hari itu belum terpenuhi (cek dari tabel `tilawah_progress`).
*   [x] Pesan dinamis: "Kamu kurang X ayat lagi untuk mencapai target hari ini! 📖"
*   [x] Tambahkan pengaturan ON/OFF + jam pengiriman reminder di halaman Settings.

#### 10. 🌙 Mode Baca Malam (Night Reader Mode)
Memberikan kenyamanan membaca Al-Quran di malam hari tanpa menyilaukan mata.
*   [ ] Tambahkan tombol "Mode Malam" di AppBar `DetailSurahView`.
*   [ ] Mode Malam: background hitam pekat `#0A0A0A`, teks Arab emas redup, font lebih besar (+4pt), tidak ada efek animasi.
*   [ ] Simpan preferensi mode ke `SharedPreferences` agar persisten.

---

### Sprint 2 — Prioritas Sedang (Nilai Tambah Signifikan)

#### 11. 📊 Statistik & Riwayat Tilawah Lengkap
Memberikan gambaran menyeluruh tentang konsistensi ibadah tilawah pengguna.
*   [ ] Halaman khusus Statistik: total ayat dibaca sepanjang masa, rata-rata harian, streak terpanjang pernah dicapai.
*   [ ] Grafik bulanan (30 hari terakhir).
*   [ ] Sistem badge/achievement: "Khatam Pertama 🏆", "Streak 7 Hari 🔥", "Baca 1000 Ayat ⭐" dll.

#### 12. 🎯 Tracker Khatam Al-Quran
Memotivasi pengguna untuk menyelesaikan seluruh bacaan Al-Quran.
*   [ ] Tracking surah mana saja yang sudah dan belum dibaca (buat tabel `surah_read_history`).
*   [ ] Tampilkan progress global di Beranda: "Sudah membaca X dari 114 Surah (Y%)".
*   [ ] Estimasi tanggal khatam berdasarkan rata-rata tilawah harian.
*   [ ] Tombol "Tandai Surah Ini Selesai" di halaman Detail Surah.

#### 13. 📤 Export & Share Catatan Tadabbur
Memudahkan pengguna berbagi refleksi ayat Al-Quran.
*   [ ] Tombol share per catatan → format teks siap kirim WhatsApp (teks Arab + terjemahan + catatan).
*   [ ] Export semua catatan ke file `.txt` yang dapat disimpan ke penyimpanan lokal.

---

### Sprint 3 — Prioritas Rendah (Diferensiasi & Premium Feel)

#### 14. 📿 Mode Hafalan (Memorization Mode)
Membantu pengguna menghafal Al-Quran secara bertahap dan sistematis.
*   [ ] Tombol "Mode Hafalan" di Detail Surah → menyembunyikan sebagian teks Arab secara acak.
*   [ ] Fitur audio loop per ayat: putar satu ayat N kali secara otomatis sebelum lanjut.
*   [ ] Tandai ayat yang sedang/sudah dihafal dengan badge khusus.
*   [ ] Buat tabel `hafalan_progress` untuk menyimpan status hafalan per ayat.

#### 15. 🔍 Pencarian Lanjut (Advanced Search)
Memperkuat kemampuan pencarian yang sudah ada.
*   [ ] Filter hasil pencarian: Makkiyah / Madaniyah.
*   [ ] Filter berdasarkan panjang surah (pendek < 20 ayat / sedang / panjang).
*   [ ] Highlight teks yang cocok dengan query di hasil pencarian.
*   [ ] Riwayat pencarian (history 10 terakhir).

#### 16. 🏠 Widget Beranda Diperluas
Mengembangkan widget Android yang sudah ada (`SholatWidgetProvider.kt`).
*   [ ] Widget baru: "Ayat Harian" — tampilkan satu ayat Al-Quran secara acak setiap hari.
*   [ ] Widget progress tilawah hari ini (bar progres ringkas).
*   [ ] Perbarui widget sholat agar juga menampilkan countdown waktu sholat berikutnya secara real-time.

#### 17. 🎨 Tema Warna Kustom
Meningkatkan personalisasi tampilan aplikasi.
*   [ ] Beberapa pilihan palet warna: Emerald (default), Biru Safir, Ungu Amethyst, Coklat Tembaga.
*   [ ] Simpan pilihan tema ke database.
*   [ ] Preview live saat memilih tema di halaman Pengaturan.



> [!TIP]
> **Manajemen State GetX:**
> Gunakan GetX CLI untuk menginisialisasi modul baru secara bersih dengan perintah:
> `get create page:nama_fitur` jika GetX CLI terpasang, atau ikuti struktur modular yang ada pada `lib/app/modules/`.

> [!IMPORTANT]
> **Registrasi Aset Suara Adzan Baru:**
> Jika menambahkan file audio adzan baru ke dalam aset Android (`android/app/src/main/res/raw/`), pastikan untuk menaikkan versi ID channel notifikasi di `NotificationHelper` (contoh: dari `sholat_channel_v3` ke `sholat_channel_v4`) agar Android meregistrasi ulang file audio baru tersebut sebagai default ringtone channel.
