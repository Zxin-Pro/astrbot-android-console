#!/usr/bin/env bash
# ============================================================
#  构建 APK（纯 aapt2 + javac + d8 + apksigner，不依赖 Gradle）
#  在 GitHub Actions 的 ubuntu runner 上运行
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [ -z "$SDK" ] || [ ! -d "$SDK" ]; then
  echo "[错误] 未找到 Android SDK（ANDROID_HOME / ANDROID_SDK_ROOT 未设置）"
  exit 1
fi

BT="$(ls -d "$SDK"/build-tools/* 2>/dev/null | sort -V | tail -1 || true)"

# 优先使用 android-34 平台，没有则退到最新
PLATFORM_API="${PLATFORM_API:-34}"
if [ -d "$SDK/platforms/android-$PLATFORM_API" ]; then
  PLATFORM="$SDK/platforms/android-$PLATFORM_API"
else
  PLATFORM="$(ls -d "$SDK"/platforms/* 2>/dev/null | sort -V | tail -1 || true)"
fi

[ -n "$BT" ] || { echo "[错误] 缺少 build-tools，请先安装"; exit 1; }
[ -n "$PLATFORM" ] || { echo "[错误] 缺少 platforms，请先安装"; exit 1; }

AAPT2="$BT/aapt2"
D8="$BT/d8"
APKSIGNER="$BT/apksigner"
ZIPALIGN="$BT/zipalign"
ANDROID_JAR="$PLATFORM/android.jar"

echo "==> build-tools : $BT"
echo "==> platform    : $PLATFORM"
echo "==> java        : $(java -version 2>&1 | head -1)"
echo

rm -rf build dist
mkdir -p build/compiled build/classes build/gen dist

echo "==> [1/6] 编译资源"
"$AAPT2" compile --dir app/res -o build/compiled/res.zip

echo "==> [2/6] 链接资源与清单"
"$AAPT2" link \
  -o build/base.apk \
  -I "$ANDROID_JAR" \
  --manifest app/AndroidManifest.xml \
  --java build/gen \
  --min-sdk-version 21 \
  --target-sdk-version 34 \
  --version-code 1 \
  --version-name "1.0.0" \
  build/compiled/res.zip

echo "==> [3/6] 编译 Java"
find app/src build/gen -name '*.java' > build/sources.txt
javac -encoding UTF-8 -source 8 -target 8 -nowarn \
  -bootclasspath "$ANDROID_JAR" \
  -d build/classes \
  @build/sources.txt

echo "==> [4/6] 生成 classes.dex"
find build/classes -name '*.class' > build/classes.txt
"$D8" --lib "$ANDROID_JAR" --min-api 21 --output build/ $(cat build/classes.txt)

echo "==> [5/6] 打包 + 对齐"
( cd build && zip -q -j base.apk classes.dex )
"$ZIPALIGN" -f -p 4 build/base.apk build/aligned.apk

echo "==> [6/6] 签名"
if [ ! -f build/ks.jks ]; then
  keytool -genkeypair \
    -keystore build/ks.jks \
    -storepass android -keypass android \
    -alias astrbot -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=AstrBot Console, OU=Minis, O=Zxin, L=CN, C=CN" >/dev/null 2>&1
fi

"$APKSIGNER" sign \
  --ks build/ks.jks \
  --ks-pass pass:android \
  --key-pass pass:android \
  --ks-key-alias astrbot \
  --v1-signing-enabled true \
  --v2-signing-enabled true \
  --out dist/astrbot-console.apk \
  build/aligned.apk

"$APKSIGNER" verify --print-certs dist/astrbot-console.apk | head -4

echo
echo "==> 构建完成"
ls -lh dist/
echo
"$AAPT2" dump badging dist/astrbot-console.apk 2>/dev/null | head -6 || true
