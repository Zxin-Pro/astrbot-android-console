import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 深夜流璃 · 主题
///
/// 整体取向：深色底 + 紫罗兰主色 + 冷调高光。
/// 与默认 Material 亮色青绿风格完全不同，全局由这里统一控制。
class AppTheme {
  AppTheme._();

  // ---------------- 品牌色板 ----------------

  /// 主色：紫罗兰。偏冷、偏亮，在深色底上很好看
  static const Color primary = Color(0xFFAB7DFF);

  /// 主色（深一档），用于渐变收尾
  static const Color primaryDeep = Color(0xFF6E3FD1);

  /// 强调色：青蓝紫，用于次级高亮
  static const Color accent = Color(0xFF6FD3FF);

  /// 背景层次（越往下越亮）
  static const Color bg = Color(0xFF0D0A14); // 最底层
  static const Color surface = Color(0xFF161121); // 卡片
  static const Color surfaceAlt = Color(0xFF1F1830); // 悬浮 / 次级面

  /// 描边
  static const Color outline = Color(0xFF3A2E52);

  /// 文字
  static const Color textPrimary = Color(0xFFF0EAFB);
  static const Color textSecondary = Color(0xFFA99BC4);

  /// 状态色
  static const Color ok = Color(0xFF5EE6A8);
  static const Color warn = Color(0xFFFFC46B);
  static const Color err = Color(0xFFFF7A8A);

  /// 主渐变（用于标题、按钮、进度条）
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDeep],
  );

  // ---------------- ThemeData ----------------

  static ThemeData build() {
    // 用 fromSeed 生成基础配色，再覆盖关键色。
    // 这样不依赖 ColorScheme 构造函数的参数名，跨 Flutter 版本更稳。
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: const Color(0xFF1A0F2E),
      primaryContainer: primaryDeep,
      onPrimaryContainer: textPrimary,
      secondary: accent,
      onSecondary: const Color(0xFF04141D),
      surface: surface,
      onSurface: textPrimary,
      outline: outline,
      error: err,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
    );

    return base.copyWith(
      // 顶栏 / 底栏
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // 卡片：深色面 + 细描边，不用阴影（深色下阴影看不出来）
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),

      // 分割线低调一点
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),

      // 列表项
      listTileTheme: const ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        selectedColor: primary,
        selectedTileColor: Color(0x22AB7DFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // 输入框
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
      ),

      // 按钮：主按钮走紫渐变，圆角更大
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF1A0F2E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),

      // 悬浮按钮
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Color(0xFF1A0F2E),
        elevation: 0,
      ),

      // 开关 / 进度
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary
              : const Color(0xFF6B5E85),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primaryDeep.withValues(alpha: 0.55)
              : surfaceAlt,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
        circularTrackColor: surfaceAlt,
      ),

      // 弹窗
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outline),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceAlt,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceAlt,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: outline),
        ),
      ),

      // 文字
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      // 下拉刷新 / Tab
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceAlt,
        selectedColor: primaryDeep,
        side: const BorderSide(color: outline),
        labelStyle: const TextStyle(color: textPrimary),
      ),
    );
  }
}
