import 'package:flutter/material.dart';
import '../../../../app/constants/r.dart';
import '../../../data/models/surah_model.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';

class SurahTile extends StatelessWidget {
  final DataSurah item;
  final Color gold, goldLight, goldDim, textSoft;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTapped;
  final VoidCallback? onTap;
  final String searchQuery;

  const SurahTile({
    super.key,
    required this.item,
    required this.gold,
    required this.goldLight,
    required this.goldDim,
    required this.textSoft,
    this.isBookmarked = false,
    this.onBookmarkTapped,
    this.onTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: gold.withValues(alpha: 0.08),
          highlightColor: gold.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: R.color.bg2.withValues(alpha: 0.6),
              border: Border.all(color: goldDim.withValues(alpha: 0.12), width: 1),
            ),
            child: Row(
              children: [
                // Nomor surah
                DiamondNumber(
                  number: item.nomor,
                  color: goldDim,
                  textColor: goldLight,
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHighlightedText(
                        item.namaLatin,
                        searchQuery,
                        style: R.textStyle.medium(
                          fontWeight: FontWeight.w600,
                          color: textSoft,
                        ).copyWith(
                          fontSize: 15,
                          fontFamily: 'Poppins',
                        ),
                        highlightColor: gold,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.jumlahAyat} Ayat • ${item.tempatTurun}',
                        style: R.textStyle.small(
                          color: textSoft.withValues(alpha: 0.4),
                        ).copyWith(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Arab & Bookmark
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.nama,
                      style: R.textStyle.large(
                        color: goldLight,
                        fontWeight: FontWeight.w500,
                      ).copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                    if (onBookmarkTapped != null) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: isBookmarked ? gold : goldDim.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        onPressed: onBookmarkTapped,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query, {
    required TextStyle style,
    required Color highlightColor,
  }) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final matches = query.toLowerCase();
    final textLower = text.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int index = textLower.indexOf(matches, start);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          color: highlightColor,
          fontWeight: FontWeight.bold,
          backgroundColor: highlightColor.withValues(alpha: 0.15),
        ),
      ));
      start = index + query.length;
      index = textLower.indexOf(matches, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
