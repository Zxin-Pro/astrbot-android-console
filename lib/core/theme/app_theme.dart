import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ds.dart';

/// 应用主题
///
/// 设计取向：安静、克制、内容优先。
/// 不使用磨砂玻璃 / 渐变面板 / 大面积投影，一律实心面 + 细描边。
class AppTheme {
  const AppTheme._();

  // ==================== 品牌色 ====================
  /// 主品牌色 —— 夜紫
  static const Color primary = Color(0xFF9B6DFF);
  static const Color primaryDeep = Color(0xFF6E3FD1);

  /// 强调色 —— 冰蓝
  static const Color accent = Color(0xFF58C8F0);

  // ==================== 深色（默认） ====================
  static const Color bg = Color(0xFF0B0910); // 页面底
  static const Color surface = Color(0xFF15121C); // 卡片
  static const Color surfaceAlt = Color(0xFF1D1926); // 输入框 / 次级面
  static const Color outline = Color(0xFF2A2436); // 描边
  static const Color textPrimary = Color(0xFFF2EEF9);
  static const Color textSecondary = Color(0xFF9A92AD);

  // ==================== 亮色 ====================
  static const Color bgLight = Color(0xFFF7F5FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF1EEF7);
  static const Color outlineLight = Color(0xFFE3DFEC);
  static const Color textPrimaryLight = Color(0xFF1B1725);
  static const Color textSecondaryLight = Color(0xFF6B6478);

  // ==================== 语义色 ====================
  static const Color ok = Color(0xFF4ADE9E);
  static const Color warn = Color(0xFFF5B95C);
  static const Color err = Color(0xFFF2687A);

  /// 品牌渐变（仅用于少数强调场景，不用于面板背景）
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, accent],
  );

  // ==================== 构建主题 ====================
  static ThemeData build({Brightness brightness = Brightness.dark}) {
    final dark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: dark ? primaryDeep : const Color(0xFFE9DEFF),
      onPrimaryContainer: dark ? textPrimary : const Color(0xFF2A0F52),
      secondary: accent,
      onSecondary: dark ? const Color(0xFF04141D) : Colors.white,
      surface: dark ? surface : surfaceLight,
      onSurface: dark ? textPrimary : textPrimaryLight,
      onSurfaceVariant: dark ? textSecondary : textSecondaryLight,
      outline: dark ? outline : outlineLight,
      outlineVariant: dark ? outline : outlineLight,
      error: err,
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? bg : bgLight,
    );

    return base.copyWith(
      // ---------- 顶栏：纯色、无阴影、无居中 ----------
      appBarTheme: AppBarThemeData(
        backgroundColor: dark ? bg : bgLight,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: Ds.s4,
        toolbarHeight: 56,
        titleTextStyle: DsText.title.copyWith(
          color: dark ? textPrimary : textPrimaryLight,
          fontSize: 19,
        ),
        iconTheme: IconThemeData(
          color: dark ? textPrimary : textPrimaryLight,
          size: Ds.iLg,
        ),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // ---------- 卡片：实心 + 细描边 ----------
      cardTheme: CardThemeData(
        color: dark ? surface : surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Ds.brLg,
          side: BorderSide(
            color: dark ? Colors.white.withValues(alpha: 0.06) : outlineLight,
            width: 1,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: dark ? Colors.white.withValues(alpha: 0.06) : outlineLight,
        thickness: 1,
        space: 1,
      ),

      // ---------- 列表项 ----------
      listTileTheme: ListTileThemeData(
        iconColor: dark ? textSecondary : textSecondaryLight,
        textColor: dark ? textPrimary : textPrimaryLight,
        selectedColor: primary,
        selectedTileColor: primary.withValues(alpha: dark ? 0.14 : 0.10),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: Ds.s4, vertical: Ds.s1),
        shape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
      ),

      // ---------- 输入框 ----------
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: dark ? surfaceAlt : surfaceAltLight,
        hintStyle: DsText.body.copyWith(
          color: (dark ? textSecondary : textSecondaryLight)
              .withValues(alpha: 0.75),
        ),
        labelStyle: DsText.label.copyWith(
          color: dark ? textSecondary : textSecondaryLight,
        ),
        floatingLabelStyle: DsText.label.copyWith(color: primary),
        errorStyle: DsText.caption.copyWith(color: err),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Ds.s4,
          vertical: Ds.s3 + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: Ds.brMd,
          borderSide: BorderSide(
            color: dark ? outline : outlineLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Ds.brMd,
          borderSide: BorderSide(
            color: dark ? outline : outlineLight,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: Ds.brMd,
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: Ds.brMd,
          borderSide: BorderSide(color: err, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: Ds.brMd,
          borderSide: BorderSide(color: err, width: 1.6),
        ),
      ),

      // ---------- 主按钮：实心 ----------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          minimumSize: const Size(0, Ds.hButton),
          padding: const EdgeInsets.symmetric(horizontal: Ds.s5),
          shape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
          elevation: 0,
          textStyle: DsText.bodyStrong,
        ),
      ),

      // ---------- 次按钮：描边 ----------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? textPrimary : textPrimaryLight,
          minimumSize: const Size(0, Ds.hButton),
          padding: const EdgeInsets.symmetric(horizontal: Ds.s5),
          side: BorderSide(color: dark ? outline : outlineLight, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
          textStyle: DsText.bodyStrong,
        ),
      ),

      // ---------- 文字按钮 ----------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
          textStyle: DsText.bodyStrong,
        ),
      ),

      // ---------- 图标按钮 ----------
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: dark ? textSecondary : textSecondaryLight,
          highlightColor: primary.withValues(alpha: 0.12),
          shape: const RoundedRectangleBorder(borderRadius: Ds.brSm),
        ),
      ),

      // ---------- 悬浮按钮 / 开关 / 滑块 ----------
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Ds.brMd),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return dark ? const Color(0xFF7A7387) : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return dark ? surfaceAlt : outlineLight;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: dark ? outline : outlineLight,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        trackHeight: 4,
      ),

      // ---------- 选中控件 ----------
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: dark ? outline : outlineLight, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return dark ? outline : outlineLight;
        }),
      ),

      // ---------- 弹窗：实心、圆角 ----------
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? surface : surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Ds.brLg),
        titleTextStyle: DsText.title.copyWith(
          color: dark ? textPrimary : textPrimaryLight,
          fontSize: 18,
        ),
        contentTextStyle: DsText.body.copyWith(
          color: dark ? textSecondary : textSecondaryLight,
        ),
      ),

      // ---------- 底部弹层 ----------
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? surface : surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Ds.rLg)),
        ),
        showDragHandle: true,
        dragHandleColor: dark ? outline : outlineLight,
      ),

      // ---------- 导航栏（未被自定义组件覆盖时的兜底）----------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.16),
        indicatorShape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          return IconThemeData(
            size: Ds.iLg,
            color: on ? primary : (dark ? textSecondary : textSecondaryLight),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          return DsText.caption.copyWith(
            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
            color: on ? primary : (dark ? textSecondary : textSecondaryLight),
          );
        }),
      ),

      // ---------- 提示条 ----------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? surfaceAlt : const Color(0xFF2B2536),
        contentTextStyle: DsText.body.copyWith(color: Colors.white),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
      ),

      // ---------- 进度指示 ----------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: dark ? outline : outlineLight,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 4,
      ),

      // ---------- 弹出菜单 ----------
      popupMenuTheme: PopupMenuThemeData(
        color: dark ? surfaceAlt : surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: Ds.brMd,
          side: BorderSide(color: Colors.transparent),
        ),
        textStyle: DsText.body.copyWith(
          color: dark ? textPrimary : textPrimaryLight,
        ),
      ),

      // ---------- 标签页 ----------
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: dark ? textSecondary : textSecondaryLight,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: DsText.bodyStrong,
        unselectedLabelStyle: DsText.body,
      ),

      // ---------- 折叠面板 ----------
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        textColor: dark ? textPrimary : textPrimaryLight,
        collapsedTextColor: dark ? textPrimary : textPrimaryLight,
        iconColor: dark ? textSecondary : textSecondaryLight,
        collapsedIconColor: dark ? textSecondary : textSecondaryLight,
        shape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
        collapsedShape: const RoundedRectangleBorder(borderRadius: Ds.brMd),
      ),

      // ---------- 滚动条 ----------
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          (dark ? Colors.white : Colors.black).withValues(alpha: 0.18),
        ),
        thickness: WidgetStateProperty.all(3),
        radius: const Radius.circular(Ds.rPill),
      ),

      // ---------- 文字主题 ----------
      textTheme: base.textTheme.apply(
        bodyColor: dark ? textPrimary : textPrimaryLight,
        displayColor: dark ? textPrimary : textPrimaryLight,
      ),
    );
  }
}
