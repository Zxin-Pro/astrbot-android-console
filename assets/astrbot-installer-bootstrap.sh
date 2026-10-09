#!/bin/bash
# ============================================================================
# 安装引导脚本（本地执行版）
#
# 说明：
#   本脚本不再从网络下载任何安装器。所有安装逻辑都在本 APK 内置的
#   astrbot-startup.sh 中，本脚本只负责调用它。
#
#   这样做的好处：
#     1. 运行时零外部依赖，不会从任何第三方仓库拉取并执行代码
#     2. 安装行为完全可预期——APK 里是什么就装什么
#     3. 不需要签名校验机制（脚本从未离开过 APK）
#
# 用法：
#   astrbot-installer-bootstrap.sh --prepare
#   astrbot-installer-bootstrap.sh --run --step <base|uv|napcat|astrbot|all|start>
# ============================================================================

set -euo pipefail

# 内置安装脚本的位置（由 App 在释放 assets 时放到同一目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILTIN_INSTALLER="$SCRIPT_DIR/astrbot-startup.sh"

# 兼容：App 也可能把它释放到 HOME 下
if [ ! -f "$BUILTIN_INSTALLER" ]; then
  BUILTIN_INSTALLER="${HOME:-/root}/astrbot-startup.sh"
fi

STATE_DIR="${HOME:-/root}/.astrbot-android/installer"

log() { printf '[AstrBot Installer] %s\n' "$*"; }
fail() {
  printf '[AstrBot Installer] ERROR: %s\n' "$*" >&2
  exit 1
}

ensure_tools() {
  command -v bash >/dev/null 2>&1 || fail 'bash is required.'
  mkdir -p "$STATE_DIR"
  [ -f "$BUILTIN_INSTALLER" ] || \
    fail "内置安装脚本缺失：$BUILTIN_INSTALLER"
  chmod +x "$BUILTIN_INSTALLER" 2>/dev/null || true
}

require_installer() {
  [ -f "$BUILTIN_INSTALLER" ] || \
    fail "内置安装脚本缺失：$BUILTIN_INSTALLER"
}

# 从内置安装脚本里解析版本号（纯 bash，不依赖 grep/sed）
detect_installer_version() {
  local line version=''
  if [ -f "$BUILTIN_INSTALLER" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in
        ASTRBOT_APP_VERSION=*)
          version="${line#ASTRBOT_APP_VERSION=}"
          version="${version%\"}"
          version="${version#\"}"
          break
          ;;
      esac
    done < "$BUILTIN_INSTALLER"
  fi
  printf '%s' "$version"
}

# 发布安装脚本状态：版本号 + 运行时副本（App 侧据此判断脚本是否就绪）
publish_installer_state() {
  local version
  version="$(detect_installer_version)"
  case "$version" in
    [0-9]*.[0-9]*.[0-9]*) ;;
    *) version='' ;;
  esac

  mkdir -p "$STATE_DIR/current"
  if [ -f "$BUILTIN_INSTALLER" ]; then
    cp -f "$BUILTIN_INSTALLER" "$STATE_DIR/current/astrbot-startup.sh"
    chmod 700 "$STATE_DIR/current/astrbot-startup.sh" 2>/dev/null || true
  fi

  if [ -n "$version" ]; then
    printf '%s\n' "$version" > "$STATE_DIR/version"
  elif [ ! -s "$STATE_DIR/version" ]; then
    printf '0.0.0\n' > "$STATE_DIR/version"
  fi
}

usage() {
  cat <<'EOF'
用法:
  astrbot-installer-bootstrap.sh --prepare
  astrbot-installer-bootstrap.sh --run --step <base|uv|napcat|astrbot|all|start>

说明:
  本安装器为本地内置版本，不联网下载任何脚本。
EOF
}

main() {
  local command="${1:---help}"
  case "$command" in
    --prepare)
      ensure_tools
      log 'Bootstrap requirements are ready.'
      # 发布脚本版本与运行时副本，并写入就绪标记，供 App 侧判断
      publish_installer_state
      : > "$STATE_DIR/bootstrap-ready" 2>/dev/null || true
      log '内置安装器就绪。'
      ;;

    --ensure|--check|--update)
      # 内置模式下这些远程操作都退化为「确认本地脚本可用」
      ensure_tools
      publish_installer_state
      case "$command" in
        --check)
          log '当前为内置安装器（offline builtin），无远程更新。'
          ;;
        --update)
          log '当前为内置安装器（offline builtin），无需更新。'
          ;;
        --ensure)
          log '内置安装器可用。'
          ;;
      esac
      ;;

    --import)
      # 保留接口：导入离线包（由内置脚本处理）
      [ "$#" -eq 2 ] || fail '--import 需要离线包路径。'
      ensure_tools
      exec bash "$BUILTIN_INSTALLER" --import "$2"
      ;;

    --run)
      shift
      require_installer
      exec bash "$BUILTIN_INSTALLER" "$@"
      ;;

    --help|-h|help) usage ;;
    *) usage; exit 2 ;;
  esac
}

main "$@"
