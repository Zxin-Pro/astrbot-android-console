import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ds.dart';
import '../../controllers/terminal_controller.dart';
import '../../widgets/app_kit.dart';
import '../launcher/launcher_page.dart';
import '../settings/settings_page.dart';
import '../terminal/terminal_tab_view.dart';
import '../webview/webview_page.dart';

/// 主容器
///
/// 负责承载三个主标签（主页 / WebUI / 终端）与底部导航。
/// 视觉上使用纯色背景 + 实心导航栏，不使用模糊或渐变面板。
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final HomeController homeController = Get.put(HomeController());
  Worker? _mainTabWorker;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainTabWorker = ever<int?>(homeController.pendingMainTabIndex, (index) {
      if (index == null || index < 0 || index > 2) return;
      _openTab(index);
      homeController.clearPendingMainTabIndex(index);
    });
  }

  @override
  void dispose() {
    _mainTabWorker?.dispose();
    super.dispose();
  }

  void _openTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _openSettings() {
    Navigator.of(context).push(_buildSettingsRoute());
  }

  void _closeSettings() {
    Navigator.of(context).maybePop();
  }

  void _handlePopInvoked(bool didPop, Object? result) {
    // WebView 页自行处理浏览器历史，无历史时回调 onBackToHome。
    if (didPop || _currentIndex != 1) return;
  }

  Route<void> _buildSettingsRoute() {
    return PageRouteBuilder<void>(
      transitionDuration: Ds.normal,
      reverseTransitionDuration: Ds.normal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SettingsPage(
              astrBotController: WebViewPage.astrBotController,
              napCatController: WebViewPage.napCatController,
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Ds.easeOut,
            reverseCurve: Curves.easeInCubic,
          ),
        );
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _currentIndex != 1,
      onPopInvokedWithResult: _handlePopInvoked,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: _buildMainTabs(),
          bottomNavigationBar: _buildBottomNav(context),
        ),
      ),
    );
  }

  Widget _buildMainTabs() {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomInset = keyboardVisible ? 0.0 : Ds.hNavBar;

    return IndexedStack(
      index: _currentIndex,
      children: [
        LauncherPage(
          onNavigate: _openTab,
          onOpenSettings: _openSettings,
        ),
        WebViewPage(
          embedded: true,
          bottomContentInset: bottomInset,
          onBackToHome: () => _openTab(0),
        ),
        TerminalTabView(
          bottomContentInset: bottomInset,
        ),
      ],
    );
  }

  /// 底部导航 —— 实心圆角条 + 三胶囊高亮
  Widget _buildBottomNav(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: dark ? AppTheme.surface : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Ds.rLg),
        ),
        border: Border(
          top: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.06)
                : AppTheme.outlineLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: Ds.hNavBar,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: '主页',
                selected: _currentIndex == 0,
                onTap: () => _openTab(0),
              ),
              _NavItem(
                icon: Icons.public_outlined,
                activeIcon: Icons.public,
                label: 'WebUI',
                selected: _currentIndex == 1,
                onTap: () => _openTab(1),
              ),
              _NavItem(
                icon: Icons.terminal_outlined,
                activeIcon: Icons.terminal_rounded,
                label: '终端',
                selected: _currentIndex == 2,
                onTap: () => _openTab(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部导航单项
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? AppTheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Ds.fast,
              curve: Ds.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: Ds.s4,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: Ds.brPill,
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: Ds.iLg,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: DsText.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
