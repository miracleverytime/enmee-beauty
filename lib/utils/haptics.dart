import 'package:flutter/services.dart';

/// Wrapper terpusat untuk haptic feedback.
///
/// - [selection] : tap ringan (tab switch, sort/filter change, search clear).
/// - [light]     : tap pada kontrol (theme toggle, sort indicator).
/// - [medium]    : tap pada aksi penting (toggle stats, FAB).
/// - [heavy]     : aksi destruktif / konfirmasi (delete, save, dialog confirm).
/// - [error]     : error (mis. gagal simpan produk).
class Haptics {
  Haptics._();

  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> light() => HapticFeedback.lightImpact();

  static Future<void> medium() => HapticFeedback.mediumImpact();

  static Future<void> heavy() => HapticFeedback.heavyImpact();

  static Future<void> error() => HapticFeedback.vibrate();
}
