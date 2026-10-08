import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ds.dart';

/// 页面背景 —— 替代原来的 BubbleBackground
///
/// 原来的实现是「粉蓝绿渐变 + 磨砂玻璃叠加」，观感偏轻浮且性能差。
/// 现在改为纯色底 + 顶部极淡的品牌色光晕，安静、省电、不抢内容。
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppTheme.bg : AppTheme.bgLight,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [
                  Color(0xFF171029), // 顶部略带品牌色
                  AppTheme.bg,
                  AppTheme.bg,
                ]
              : const [
                  Color(0xFFF3EFFF),
                  AppTheme.bgLight,
                  AppTheme.bgLight,
                ],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// 标准卡片 —— 替代 GlassPanel
///
/// 实心表面 + 1px 描边 + 极淡投影。可选 onTap 变可点击态。
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final bool outlined;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.outlined = true,
    this.radius = Ds.rLg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = color ?? (dark ? AppTheme.surface : AppTheme.surfaceLight);

    final content = Container(
      padding: padding ?? const EdgeInsets.all(Ds.s4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: outlined
            ? Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              )
            : null,
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap == null) return Padding(padding: margin ?? EdgeInsets.zero, child: content);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      ),
    );
  }
}

/// 区块标题 —— 卡片组的标题行
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Ds.s1, Ds.s5, Ds.s1, Ds.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DsText.section.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Ds.s1),
                  Text(
                    subtitle!,
                    style: DsText.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 状态徽章
enum BadgeTone { neutral, ok, warn, error, brand }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (fg, bg) = switch (tone) {
      BadgeTone.ok => (AppTheme.ok, AppTheme.ok.withValues(alpha: dark ? 0.16 : 0.12)),
      BadgeTone.warn => (AppTheme.warn, AppTheme.warn.withValues(alpha: dark ? 0.16 : 0.12)),
      BadgeTone.error => (AppTheme.err, AppTheme.err.withValues(alpha: dark ? 0.16 : 0.12)),
      BadgeTone.brand =>
          (AppTheme.primary, AppTheme.primary.withValues(alpha: dark ? 0.18 : 0.12)),
      BadgeTone.neutral => (
          dark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
          (dark ? Colors.white : Colors.black).withValues(alpha: 0.06),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Ds.s2, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Ds.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: Ds.iSm * 0.8, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: DsText.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 主按钮
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool danger;
  final bool small;
  final bool block;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.filled = true,
    this.danger = false,
    this.small = false,
    this.block = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = danger ? AppTheme.err : AppTheme.primary;

    final btn = filled
        ? FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: accent.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
              minimumSize: Size(0, small ? Ds.hButtonSm : Ds.hButton),
              padding: EdgeInsets.symmetric(horizontal: small ? Ds.s4 : Ds.s5),
              shape: RoundedRectangleBorder(borderRadius: Ds.brMd),
              elevation: 0,
            ),
            child: _content(),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: danger ? AppTheme.err : (dark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
              side: BorderSide(
                color: danger
                    ? AppTheme.err.withValues(alpha: 0.5)
                    : (dark ? Colors.white24 : Colors.black26),
              ),
              minimumSize: Size(0, small ? Ds.hButtonSm : Ds.hButton),
              padding: EdgeInsets.symmetric(horizontal: small ? Ds.s4 : Ds.s5),
              shape: RoundedRectangleBorder(borderRadius: Ds.brMd),
            ),
            child: _content(),
          );

    return block ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  Widget _content() {
    if (icon == null) {
      return Text(label, style: DsText.bodyStrong.copyWith(fontSize: small ? 13 : 14));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: small ? Ds.iSm : Ds.iMd),
        const SizedBox(width: Ds.s2),
        Text(label, style: DsText.bodyStrong.copyWith(fontSize: small ? 13 : 14)),
      ],
    );
  }
}

/// 空状态
class AppEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  final Widget? action;

  const AppEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Ds.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Ds.s4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DsText.bodyStrong.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: Ds.s2),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: DsText.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Ds.s5),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 列表条目 —— 统一的设置项 / 功能项样式
class AppTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;

  const AppTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Ds.s4,
            vertical: dense ? Ds.s3 : Ds.s4,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: dark ? 0.16 : 0.12),
                    borderRadius: Ds.brSm,
                  ),
                  child: Icon(icon, size: Ds.iMd, color: AppTheme.primary),
                ),
                const SizedBox(width: Ds.s3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DsText.bodyStrong.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: DsText.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: Ds.s2),
                trailing!,
              ] else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: Ds.iMd,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
