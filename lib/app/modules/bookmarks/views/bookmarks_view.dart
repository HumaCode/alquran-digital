import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import '../../../routes/app_pages.dart';
import '../controllers/bookmarks_controller.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';

class BookmarksView extends GetView<BookmarksController> {
  const BookmarksView({super.key});

  Color get _bg => R.color.bg1;
  Color get _surface => R.color.bg2;
  Color get _gold => R.color.gold;
  Color get _goldLight => R.color.goldLight;
  Color get _goldDim => R.color.goldDim;
  Color get _text => R.color.textSoft;
  Color get _textMuted => R.color.textMuted;
  Color get _red => R.color.red;

  @override
  Widget build(BuildContext context) {
    // Refresh bookmarks list & notes list every time the view is shown
    controller.fetchBookmarks();
    controller.fetchNotes();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _surface,
          elevation: 0,
          title: Text(
            'Simpan & Catatan',
            style: R.textStyle.extraLargeBold.copyWith(color: _goldLight),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _goldLight, size: 20),
            onPressed: () => Get.back(),
          ),
          bottom: TabBar(
            indicatorColor: _gold,
            labelColor: _goldLight,
            unselectedLabelColor: _textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
            tabs: const [
              Tab(text: 'Bookmark Ayat'),
              Tab(text: 'Catatan Tadabbur'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookmarkTab(context),
            _buildNotesTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomLoader(size: 50),
              const SizedBox(height: 16),
              Text(
                'Memuat bookmark...',
                style: R.textStyle.medium(color: _textMuted),
              ),
            ],
          ),
        );
      }

      if (controller.bookmarksList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _surface,
                    border: Border.all(color: _goldDim.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: _goldDim,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Belum Ada Bookmark',
                  style: R.textStyle.largeBold.copyWith(color: _goldLight),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda bisa menandai ayat Al-Qur\'an favorit dengan menekan tombol bookmark pada halaman baca surah.',
                  textAlign: TextAlign.center,
                  style: R.textStyle.medium(color: _textMuted),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.bookmarksList.length,
        itemBuilder: (context, index) {
          final item = controller.bookmarksList[index];
          final nomorSurah = item['nomorSurah'] as int;
          final namaSurah = item['namaSurah'] as String;
          final nomorAyat = item['nomorAyat'] as int;
          final teksArab = item['teksArab'] as String;
          final teksIndonesia = item['teksIndonesia'] as String;

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _goldDim.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Get.toNamed(
                  Routes.DETAIL_SURAH,
                  arguments: {
                    'nomor': nomorSurah,
                    'ayat': nomorAyat,
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card (QS & Delete Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _goldDim.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'QS. $namaSurah [$nomorSurah:$nomorAyat]',
                            style: R.textStyle.smallBold.copyWith(color: _goldLight),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: _red, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _showDeleteConfirmation(context, nomorSurah, namaSurah, nomorAyat);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Teks Arab
                    Text(
                      teksArab,
                      textAlign: TextAlign.right,
                      style: R.textStyle.large(
                        color: _goldLight,
                        fontWeight: FontWeight.w500,
                      ).copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Teks Terjemahan
                    Text(
                      teksIndonesia,
                      textAlign: TextAlign.left,
                      style: R.textStyle.medium(color: _text),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildNotesTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomLoader(size: 50),
              const SizedBox(height: 16),
              Text(
                'Memuat catatan...',
                style: R.textStyle.medium(color: _textMuted),
              ),
            ],
          ),
        );
      }

      if (controller.notesList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _surface,
                    border: Border.all(color: _goldDim.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 64,
                    color: _goldDim,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Belum Ada Catatan',
                  style: R.textStyle.largeBold.copyWith(color: _goldLight),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda bisa menulis refleksi atau catatan pribadi pada ayat Al-Qur\'an dengan menekan tombol catatan pada halaman baca surah.',
                  textAlign: TextAlign.center,
                  style: R.textStyle.medium(color: _textMuted),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.notesList.length,
        itemBuilder: (context, index) {
          final item = controller.notesList[index];
          final nomorSurah = item['nomorSurah'] as int;
          final namaSurah = item['namaSurah'] as String;
          final nomorAyat = item['nomorAyat'] as int;
          final teksCatatan = item['teksCatatan'] as String;

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _goldDim.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Get.toNamed(
                  Routes.DETAIL_SURAH,
                  arguments: {
                    'nomor': nomorSurah,
                    'ayat': nomorAyat,
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card (QS & Actions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _goldDim.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'QS. $namaSurah [$nomorSurah:$nomorAyat]',
                            style: R.textStyle.smallBold.copyWith(color: _goldLight),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_rounded, color: _gold, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _showEditNoteDialog(context, item);
                              },
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: _red, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _showDeleteNoteConfirmation(context, nomorSurah, namaSurah, nomorAyat);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Teks Catatan
                    Text(
                      teksCatatan,
                      textAlign: TextAlign.left,
                      style: R.textStyle.medium(color: R.color.text).copyWith(
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _showDeleteConfirmation(BuildContext context, int nomorSurah, String namaSurah, int nomorAyat) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: _surface,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseWaveIcon(
                icon: Icons.delete_forever_rounded,
                color: _red,
              ),
              const SizedBox(height: 20),
              Text(
                'Hapus Bookmark',
                style: R.textStyle.largeBold.copyWith(color: _text),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus QS. $namaSurah [$nomorSurah:$nomorAyat] dari daftar bookmark?',
                textAlign: TextAlign.center,
                style: R.textStyle.medium(color: _textMuted),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _goldDim.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'Batal',
                        style: R.textStyle.medium(color: _textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        controller.deleteBookmark(nomorSurah, nomorAyat);
                        Get.back();
                        CustomToast.show(
                          context,
                          message: 'Bookmark QS. $namaSurah [$nomorSurah:$nomorAyat] berhasil dihapus',
                          type: ToastType.success,
                        );
                      },
                      child: Text(
                        'Hapus',
                        style: R.textStyle.mediumBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteNoteConfirmation(BuildContext context, int nomorSurah, String namaSurah, int nomorAyat) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: _surface,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseWaveIcon(
                icon: Icons.delete_forever_rounded,
                color: _red,
              ),
              const SizedBox(height: 20),
              Text(
                'Hapus Catatan',
                style: R.textStyle.largeBold.copyWith(color: _text),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus catatan untuk QS. $namaSurah [$nomorSurah:$nomorAyat]?',
                textAlign: TextAlign.center,
                style: R.textStyle.medium(color: _textMuted),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _goldDim.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'Batal',
                        style: R.textStyle.medium(color: _textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        controller.deleteNote(nomorSurah, nomorAyat);
                        Get.back();
                        CustomToast.show(
                          context,
                          message: 'Catatan QS. $namaSurah [$nomorSurah:$nomorAyat] berhasil dihapus',
                          type: ToastType.success,
                        );
                      },
                      child: Text(
                        'Hapus',
                        style: R.textStyle.mediumBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, Map<String, dynamic> item) {
    final nomorSurah = item['nomorSurah'] as int;
    final namaSurah = item['namaSurah'] as String;
    final nomorAyat = item['nomorAyat'] as int;
    final teksCatatan = item['teksCatatan'] as String;
    final textCtrl = TextEditingController(text: teksCatatan);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: _goldDim.withValues(alpha: 0.15)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _goldDim.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: _goldLight, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Ubah Catatan Ayat $nomorAyat',
                    style: R.textStyle.medium(
                      color: _goldLight,
                      fontWeight: FontWeight.bold,
                    ).copyWith(fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'QS. $namaSurah : Ayat $nomorAyat',
                style: R.textStyle.small(color: _text).copyWith(fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                style: TextStyle(color: R.color.text, fontSize: 14, fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  hintText: 'Tulis tadabbur, refleksi, atau catatan penting...',
                  hintStyle: TextStyle(color: _text.withValues(alpha: 0.5), fontSize: 13),
                  filled: true,
                  fillColor: _surface.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _goldDim.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _gold),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _goldDim.withValues(alpha: 0.2)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: _text, fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.saveNote(nomorSurah, namaSurah, nomorAyat, textCtrl.text);
                      Get.back();
                      CustomToast.show(
                        context,
                        message: 'Catatan ayat $nomorAyat berhasil diubah',
                        type: ToastType.success,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
