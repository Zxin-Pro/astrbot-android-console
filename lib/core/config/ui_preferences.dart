import 'dart:convert';

import 'package:settings/settings.dart';

class UiPreferences {
  static SettingNode get _terminalFontSize => 'terminal_font_size'.setting;
  static SettingNode get _showTerminalShortcutBar =>
      'show_terminal_shortcut_bar'.setting;
  static SettingNode get _webUiZoomLevels => 'web_ui_zoom_levels'.setting;

  // 以下外观项已从设置页移除，统一使用固定默认值。
  // The appearance options below were removed from the settings page and now
  // always fall back to fixed defaults.
  static const String homeBackgroundPath = '';
  static const double cardGlassOpacity = 0.62;
  static const double glassBlurAmount = 0.45;
  static const double topNavGlassOpacity = 0.62;
  static const double statusOverlayOpacity = 0.38;
  static const double terminalOverlayOpacity = 0.55;
  static const double homeFontScale = 1.0;

  static double get terminalFontSize =>
      _readDouble(_terminalFontSize, 13.0).clamp(10.0, 22.0).toDouble();
  static bool get showTerminalShortcutBar =>
      _readBool(_showTerminalShortcutBar, true);
  static Map<String, int> get webUiZoomLevels {
    final value = _webUiZoomLevels.get();
    if (value == null) return {};

    try {
      final decoded = value is String ? jsonDecode(value) : value;
      if (decoded is! Map) return {};

      final zoomLevels = <String, int>{};
      for (final entry in decoded.entries) {
        final zoom = entry.value is num
            ? (entry.value as num).toInt()
            : int.tryParse(entry.value.toString());
        if (zoom != null) {
          zoomLevels[entry.key.toString()] = zoom.clamp(50, 150).toInt();
        }
      }
      return zoomLevels;
    } catch (_) {
      return {};
    }
  }

  static void saveTerminalFontSize(double value) {
    _terminalFontSize.set(value.clamp(10.0, 22.0).toDouble());
  }

  static void saveShowTerminalShortcutBar(bool value) {
    _showTerminalShortcutBar.set(value);
  }

  static void saveWebUiZoomLevels(Map<String, int> value) {
    final normalized = value.map(
      (key, zoom) => MapEntry(key, zoom.clamp(50, 150).toInt()),
    );
    _webUiZoomLevels.set(jsonEncode(normalized));
  }

  static double _readDouble(SettingNode node, double fallback) {
    final value = node.get();
    return value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _readBool(SettingNode node, bool fallback) {
    final value = node.get();
    if (value is bool) return value;
    if (value?.toString().toLowerCase() == 'true') return true;
    if (value?.toString().toLowerCase() == 'false') return false;
    return fallback;
  }
}