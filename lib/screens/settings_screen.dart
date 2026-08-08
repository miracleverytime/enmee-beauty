import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const PageHeader(title: 'Pengaturan'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingSection(
                    'Tampilan',
                    [
                      _buildThemeSwitch(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingSection(
                    'Umum',
                    [
                      _buildSettingItem(
                        Icons.store_outlined,
                        'Informasi Toko',
                        'Nama toko, alamat, kontak',
                        () {},
                      ),
                      _buildSettingItem(
                        Icons.receipt_long_outlined,
                        'Format Nota',
                        'Atur format cetak nota',
                        () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingSection(
                    'Data',
                    [
                      _buildSettingItem(
                        Icons.backup_outlined,
                        'Backup Data',
                        'Cadangkan database',
                        () {},
                      ),
                      _buildSettingItem(
                        Icons.restore_outlined,
                        'Restore Data',
                        'Pulihkan dari backup',
                        () {},
                      ),
                      _buildSettingItem(
                        Icons.delete_outline,
                        'Hapus Semua Data',
                        'Reset database',
                        () {},
                        isDestructive: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingSection(
                    'Tentang',
                    [
                      _buildSettingItem(
                        Icons.info_outline,
                        'Versi Aplikasi',
                        'v1.0.0',
                        null,
                      ),
                      _buildSettingItem(
                        Icons.help_outline,
                        'Bantuan',
                        'Panduan penggunaan',
                        () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitch() {
    final isDark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => SkincareApp.of(context)?.toggleTheme(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined,
                  size: 20,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode Gelap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDark ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDark,
                onChanged: (_) => SkincareApp.of(context)?.toggleTheme(),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.textMuted,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.borderColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? context.destructiveColor.withOpacity(0.1)
                      : context.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? context.destructiveColor : context.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? context.destructiveColor : context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: context.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

}
