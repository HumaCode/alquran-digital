import 'package:flutter/material.dart';
import '../../../../app/constants/r.dart';
import 'surah_item.dart';
import 'diamond_number_painter.dart';

class SurahTile extends StatelessWidget {
  final SurahItem item;
  final Color gold, goldLight, goldDim, textSoft;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTapped;

  const SurahTile({
    super.key,
    required this.item,
    required this.gold,
    required this.goldLight,
    required this.goldDim,
    required this.textSoft,
    this.isBookmarked = false,
    this.onBookmarkTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          splashColor: gold.withOpacity(0.08),
          highlightColor: gold.withOpacity(0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: R.color.bg2.withOpacity(0.6),
              border: Border.all(color: goldDim.withOpacity(0.12), width: 1),
            ),
            child: Row(
              children: [
                // Nomor surah
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: const Size(40, 40),
                    painter: DiamondNumberPainter(
                      number: item.number,
                      color: goldDim,
                      textColor: goldLight,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.latin,
                        style: R.textStyle.medium(
                          fontWeight: FontWeight.w600,
                          color: textSoft,
                        ).copyWith(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.verses} Ayat • ${item.type}',
                        style: R.textStyle.small(
                          color: textSoft.withOpacity(0.4),
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
                      item.arabic,
                      style: R.textStyle.large(
                        color: goldLight,
                        fontWeight: FontWeight.w500,
                      ).copyWith(
                        fontFamily: 'serif',
                        fontSize: 18,
                      ),
                    ),
                    if (onBookmarkTapped != null) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: isBookmarked ? gold : goldDim.withOpacity(0.6),
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
}
