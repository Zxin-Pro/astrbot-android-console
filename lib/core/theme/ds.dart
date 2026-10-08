import 'package:flutter/material.dart';

/// 设计令牌（Design Tokens）
///
/// 全应用唯一的尺寸/间距/圆角/动效来源。
/// 页面里禁止再出现魔法数字，一律引用这里。
class Ds {
  const Ds._();

  // ---------- 间距（8pt 栅格）----------
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;

  /// 页面左右统一留白
  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: s4);

  /// 页面整体内边距
  static const EdgeInsets page =
      EdgeInsets.fromLTRB(s4, s2, s4, s6);

  // ---------- 圆角 ----------
  static const double rSm = 10;
  static const double rMd = 14;
  static const double rLg = 20;
  static const double rPill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(rPill));

  // ---------- 控件高度 ----------
  static const double hInput = 48;
  static const double hButton = 48;
  static const double hButtonSm = 38;
  static const double hNavBar = 62;
  static const double hTile = 60;

  // ---------- 图标尺寸 ----------
  static const double iSm = 16;
  static const double iMd = 20;
  static const double iLg = 24;
  static const double iXl = 32;

  // ---------- 动效 ----------
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 380);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
}

/// 文字样式（不含颜色，颜色由主题的 textTheme 注入）
class DsText {
  const DsText._();

  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle section = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    height: 1.5,
  );
}
