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
    // Refresh bookmarks list every time the view is shown
    controller.fetchBookmarks();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Text(
          'Bookmark Ayat',
          style: R.textStyle.extraLargeBold.copyWith(color: _goldLight),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _goldLight, size: 20),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            color: _goldDim.withValues(alpha: 0.15),
          ),
        ),
      ),
      body: Obx(() {
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
      }),
    );
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
}
