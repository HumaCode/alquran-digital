import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/r.dart';
import '../../../data/providers/theme_controller.dart';
import '../../home/controllers/home_controller.dart';
import 'package:alquran_digital/app/components/widgets/widgets.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final HomeController _homeController = Get.find<HomeController>();

  Color get _bg => R.color.bg1;
  Color get _bg2 => R.color.bg2;
  Color get _gold => R.color.gold;
  Color get _goldLight => R.color.goldLight;
  Color get _goldDim => R.color.goldDim;
  Color get _textSoft => R.color.textSoft;
  Color get _textMuted => R.color.textMuted;
  Color get _primary => R.color.emerald;

  final List<Map<String, dynamic>> _themeOptions = [
    {
      'id': 'emerald',
      'name': 'Emerald Green',
      'color': const Color(0xFF2E7D52),
      'lightColor': const Color(0xFF4CAF82),
    },
    {
      'id': 'sapphire',
      'name': 'Biru Safir',
      'color': const Color(0xFF0284C7),
      'lightColor': const Color(0xFF38BDF8),
    },
    {
      'id': 'amethyst',
      'name': 'Ungu Amethyst',
      'color': const Color(0xFF9333EA),
      'lightColor': const Color(0xFFC084FC),
    },
    {
      'id': 'copper',
      'name': 'Coklat Tembaga',
      'color': const Color(0xFFD97706),
      'lightColor': const Color(0xFFFBBF24),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Force react to theme and mode modifications
      final activeThemeId = ThemeController.to.currentThemeColor.value;
      final isDark = ThemeController.to.isDarkMode.value;

      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg2,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _gold),
            onPressed: () => Get.back(),
          ),
          title: Text(
            R.string.settingsTitle,
            style: R.textStyle.mediumBold.copyWith(color: _goldLight, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Live Preview Section
                Text(
                  R.string.settingsLivePreview,
                  style: R.textStyle.medium(fontWeight: FontWeight.bold, color: _goldLight),
                ),
                const SizedBox(height: 12),
                _buildLivePreviewCard(activeThemeId, isDark),
                const SizedBox(height: 28),

                // 2. Theme Selection Section
                Text(
                  R.string.settingsCustomTheme,
                  style: R.textStyle.medium(fontWeight: FontWeight.bold, color: _goldLight),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _bg2.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _goldDim.withValues(alpha: 0.15)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Mode Gelap Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                color: _gold,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    R.string.settingsDarkMode,
                                    style: R.textStyle.mediumBold.copyWith(color: _textSoft),
                                  ),
                                  Text(
                                    R.string.settingsDarkModeDesc,
                                    style: R.textStyle.small(color: _textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: isDark,
                            activeThumbColor: _gold,
                            activeTrackColor: _goldDim.withValues(alpha: 0.4),
                            onChanged: (val) {
                              ThemeController.to.toggleTheme();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: _goldDim.withValues(alpha: 0.15), height: 1),
                      const SizedBox(height: 16),

                      // Color Options List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _themeOptions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final option = _themeOptions[index];
                          final isSelected = activeThemeId == option['id'];

                          return InkWell(
                            onTap: () {
                              ThemeController.to.setThemeColor(option['id'] as String);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (option['color'] as Color).withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? (option['color'] as Color).withValues(alpha: 0.6)
                                      : _goldDim.withValues(alpha: 0.08),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [option['color'] as Color, option['lightColor'] as Color],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      option['name'] as String,
                                      style: R.textStyle.mediumBold.copyWith(
                                        color: isSelected ? _goldLight : _textSoft,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (option['color'] as Color).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        R.string.settingsActive,
                                        style: R.textStyle.smallBold.copyWith(
                                          color: option['lightColor'] as Color,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Tilawah Tracker settings
                Text(
                  R.string.settingsDailyTilawahTitle,
                  style: R.textStyle.medium(fontWeight: FontWeight.bold, color: _goldLight),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _bg2.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _goldDim.withValues(alpha: 0.15)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target harian
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                R.string.tilawahTargetTitle,
                                style: R.textStyle.mediumBold.copyWith(color: _textSoft),
                              ),
                              Text(
                                R.string.settingsDailyTilawahDesc,
                                style: R.textStyle.small(color: _textMuted),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _primary.withValues(alpha: 0.2)),
                            ),
                            child: InkWell(
                              onTap: () => _showTargetDialog(context),
                              child: Text(
                                '${_homeController.tilawahTarget.value} Ayat',
                                style: R.textStyle.mediumBold.copyWith(color: _gold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: _goldDim.withValues(alpha: 0.15), height: 1),
                      const SizedBox(height: 16),

                      // Pengingat harian switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                R.string.settingsReminderTitle,
                                style: R.textStyle.mediumBold.copyWith(color: _textSoft),
                              ),
                              Text(
                                R.string.settingsReminderDesc,
                                style: R.textStyle.small(color: _textMuted),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: _homeController.tilawahReminderEnabled.value,
                            activeThumbColor: _gold,
                            activeTrackColor: _goldDim.withValues(alpha: 0.4),
                            onChanged: (val) {
                              _homeController.toggleTilawahReminder(val);
                            },
                          ),
                        ],
                      ),

                      // Jam pengingat jika aktif
                      if (_homeController.tilawahReminderEnabled.value) ...[
                        const SizedBox(height: 16),
                        Divider(color: _goldDim.withValues(alpha: 0.15), height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  R.string.settingsReminderTimeTitle,
                                  style: R.textStyle.mediumBold.copyWith(color: _textSoft),
                                ),
                                Text(
                                  R.string.settingsReminderTimeDesc,
                                  style: R.textStyle.small(color: _textMuted),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _goldDim.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _selectTime(context),
                                child: Text(
                                  _formatTime(
                                    _homeController.tilawahReminderHour.value,
                                    _homeController.tilawahReminderMinute.value,
                                  ),
                                  style: R.textStyle.mediumBold.copyWith(color: _goldLight),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    });
  }

  // A beautiful mini-mockup of detail surah or app UI to preview live color changes
  Widget _buildLivePreviewCard(String activeThemeId, bool isDark) {
    Color cardBg = isDark ? _bg2 : Colors.white;
    Color borderCol = _goldDim.withValues(alpha: 0.15);
    Color previewText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '١',
                  style: R.textStyle.mediumBold.copyWith(color: _primary),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Al-Fatihah',
                    style: R.textStyle.mediumBold.copyWith(color: previewText, fontSize: 13),
                  ),
                  Text(
                    'Pembukaan • 7 Ayat',
                    style: R.textStyle.small(color: _textMuted).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: _goldDim.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 16),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.right,
            style: R.textStyle.largeBold.copyWith(
              color: previewText,
              fontFamily: 'Poppins',
              fontSize: 18,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
            style: R.textStyle.small(color: _textMuted).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_arrow_rounded, color: _primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Putar Murotal',
                      style: R.textStyle.smallBold.copyWith(color: _primary, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showTargetDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _homeController.tilawahTarget.value.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bg2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _gold.withValues(alpha: 0.2)),
          ),
          title: Text(
            R.string.tilawahSetTargetTitle,
            style: R.textStyle.medium(fontWeight: FontWeight.bold, color: _goldLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                R.string.tilawahSetTargetSubtitle,
                style: R.textStyle.small(color: _textSoft),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: R.textStyle.medium(color: _goldLight),
                decoration: InputDecoration(
                  labelText: R.string.tilawahTargetLabel,
                  labelStyle: TextStyle(color: _goldDim),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _gold.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _gold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(R.string.cancel, style: TextStyle(color: _textSoft)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final target = int.tryParse(controller.text) ?? 10;
                _homeController.updateDailyTarget(target);
                Navigator.of(context).pop();
                CustomToast.show(context, message: R.string.settingsToastTargetSaved);
              },
              child: Text(
                R.string.save,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _homeController.tilawahReminderHour.value,
        minute: _homeController.tilawahReminderMinute.value,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _gold,
              onPrimary: _bg,
              surface: _bg2,
              onSurface: _textSoft,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: _bg,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _homeController.updateTilawahReminderTime(picked.hour, picked.minute);
      if (!context.mounted) return;
      CustomToast.show(context, message: R.string.settingsToastReminderSaved);
    }
  }

  String _formatTime(int hour, int minute) {
    final hStr = hour.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');
    return '$hStr:$mStr';
  }
}
