import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alquran_digital/app/routes/app_pages.dart';
import '../../../../app/constants/r.dart';
import '../../../data/models/detail_surah_model.dart';
import '../../home/widgets/diamond_number_painter.dart';
import '../controllers/detail_surah_controller.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';

class DetailSurahView extends GetView<DetailSurahController> {
  const DetailSurahView({super.key});

  static final Color _bg = R.color.bg1;
  static final Color _gold = R.color.gold;
  static final Color _goldLight = R.color.goldLight;
  static final Color _goldDim = R.color.goldDim;
  static final Color _textSoft = R.color.textSoft;
  static final Color _bg2 = R.color.bg2;
  static final Color _emeraldDark = R.color.emeraldDark;
  static final Color _emeraldMedium = R.color.emeraldMedium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _goldLight),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final title = controller.detailSurah.value?.data.namaLatin ?? R.string.loading;
          return Text(
            title,
            style: R.textStyle.large(
              color: _goldLight,
              fontWeight: FontWeight.bold,
            ).copyWith(fontSize: 20),
          );
        }),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CustomLoader(size: 60),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: R.textStyle.medium(color: _textSoft),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchDetailSurah(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(R.string.tryAgain),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final detailResponse = controller.detailSurah.value;
        if (detailResponse == null) {
          return Center(
            child: Text(
              R.string.detailSurahNotFound,
              style: R.textStyle.medium(color: _textSoft),
            ),
          );
        }

        final detail = detailResponse.data;

        return ListView(
          controller: controller.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Surah Card Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_emeraldDark, _emeraldMedium],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _goldDim.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    detail.namaLatin,
                    style: R.textStyle.large(
                      color: _goldLight,
                      fontWeight: FontWeight.bold,
                    ).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.arti,
                    style: R.textStyle.medium(
                      color: _textSoft.withValues(alpha: 0.7),
                    ).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: _goldDim.withValues(alpha: 0.3),
                    thickness: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        detail.tempatTurun.toUpperCase(),
                        style: R.textStyle.small(
                          color: _goldLight,
                          fontWeight: FontWeight.w600,
                        ).copyWith(letterSpacing: 1.5, fontSize: 12),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.circle, color: _goldDim, size: 6),
                      ),
                      Text(
                        '${detail.jumlahAyat} AYAT',
                        style: R.textStyle.small(
                          color: _goldLight,
                          fontWeight: FontWeight.w600,
                        ).copyWith(letterSpacing: 1.5, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Beautiful Bismillah (except for Al-Fatihah which has it as verse 1 and At-Tawbah which does not have it)
                  if (detail.nomor != 1 && detail.nomor != 9)
                    Text(
                      R.string.bismillah,
                      textAlign: TextAlign.center,
                      style: R.textStyle.large(
                        color: _goldLight,
                      ).copyWith(
                        fontSize: 24,
                        letterSpacing: 1,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Ayat List ──────────────────────────────────────────────────
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.visibleAyat.length,
              itemBuilder: (context, index) {
                final ayat = controller.visibleAyat[index];
                final key = controller.ayatKeys.putIfAbsent(ayat.nomorAyat, () => GlobalKey());
                return Padding(
                  key: key,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _bg2.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _goldDim.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Ayat Header (Number & Action Bar)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _bg2.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: CustomPaint(
                                  size: const Size(36, 36),
                                  painter: DiamondNumberPainter(
                                    number: ayat.nomorAyat,
                                    color: _goldDim,
                                    textColor: _goldLight,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Play Audio Button
                              IconButton(
                                icon: Obx(() {
                                  final isPlaying = controller.currentlyPlayingAyat.value == ayat.nomorAyat &&
                                      controller.isAudioPlaying.value;
                                  return Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: isPlaying ? _gold : _goldDim,
                                    size: 22,
                                  );
                                }),
                                onPressed: () {
                                  controller.togglePlayAudio(ayat);
                                },
                              ),
                              // Tandai Terakhir Dibaca Button
                              IconButton(
                                icon: Obx(() => Icon(
                                      controller.lastReadAyatNomor.value == ayat.nomorAyat
                                          ? Icons.bookmark_added_rounded
                                          : Icons.bookmark_add_outlined,
                                      color: controller.lastReadAyatNomor.value == ayat.nomorAyat
                                          ? _gold
                                          : _goldDim,
                                      size: 20,
                                    )),
                                onPressed: () {
                                  controller.markAsLastRead(
                                    detail.nomor,
                                    detail.namaLatin,
                                    ayat.nomorAyat,
                                  );
                                  CustomToast.show(
                                    context,
                                    message: 'Ayat ${ayat.nomorAyat} ditandai sebagai terakhir dibaca',
                                    type: ToastType.success,
                                  );
                                },
                              ),
                              // Copy Button
                              IconButton(
                                icon: Icon(Icons.copy_rounded, color: _goldDim, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: '${ayat.teksArab}\n${ayat.teksLatin}\n${ayat.teksIndonesia}',
                                  ));
                                  CustomToast.show(
                                    context,
                                    message: 'Ayat ${ayat.nomorAyat} ${R.string.copySuccess.toLowerCase()}',
                                    type: ToastType.success,
                                  );
                                },
                              ),
                              // Share Button
                              IconButton(
                                icon: Icon(Icons.share_rounded, color: _goldDim, size: 20),
                                onPressed: () {
                                  // Share content (simple copy notification as fallback)
                                  Clipboard.setData(ClipboardData(
                                    text: 'QS. ${detail.namaLatin} [${detail.nomor}:${ayat.nomorAyat}]\n\n'
                                        '${ayat.teksArab}\n\n'
                                        'Artinya: "${ayat.teksIndonesia}"',
                                  ));
                                  CustomToast.show(
                                    context,
                                    message: R.string.shareText,
                                    type: ToastType.success,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Arabic Text
                        Text(
                          ayat.teksArab,
                          textAlign: TextAlign.right,
                          style: R.textStyle.large(
                            color: _goldLight,
                            fontWeight: FontWeight.w500,
                          ).copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Latin text
                        Text(
                          ayat.teksLatin,
                          textAlign: TextAlign.left,
                          style: R.textStyle.medium(
                            color: _gold.withValues(alpha: 0.9),
                          ).copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Translation (Indonesian)
                        Text(
                          ayat.teksIndonesia,
                          textAlign: TextAlign.left,
                          style: R.textStyle.small(
                            color: _textSoft.withValues(alpha: 0.8),
                          ).copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
            
            // Loading Indicator for Pagination
            Obx(() {
              if (controller.isMoreLoading.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_gold),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            const SizedBox(height: 24),

            // ── Next & Previous Buttons ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (detail.suratSebelumnya != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to previous surah with replacement so stack doesn't grow indefinitely
                        Get.offNamed(
                          Routes.DETAIL_SURAH,
                          arguments: detail.suratSebelumnya!.nomor,
                        );
                      },
                      icon: Icon(Icons.arrow_back_ios_rounded, size: 16, color: _goldLight),
                      label: Text(
                        detail.suratSebelumnya!.namaLatin,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _goldLight, fontFamily: 'Poppins'),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _goldDim),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 16),
                if (detail.suratSelanjutnya != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to next surah with replacement
                        Get.offNamed(
                          Routes.DETAIL_SURAH,
                          arguments: detail.suratSelanjutnya!.nomor,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _bg,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              detail.suratSelanjutnya!.namaLatin,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }
}
