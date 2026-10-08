# AstrBot 控制台（Android）

> 把「手机本地跑 AstrBot + NapCat」这套链路，收进一个 App。
> 内嵌管理面板 + 一键调用 Termux 完成安装、启停、登录、看日志。

---

## 这是什么

配套 [安卓懒人包](https://github.com/Zxin-Pro/astrbot-android-console/tree/main/pack) 使用的**手机端控制台**。

它本身不跑 AstrBot（QQ 和 AstrBot 跑在 Termux 的 Debian 容器里），
而是把日常要用到的操作全部收拢到一个界面里：

| 区域 | 功能 |
|---|---|
| 顶部按钮 | 在 **AstrBot 面板(6185)** 和 **NapCat 面板(6099)** 之间切换 |
| 中间 | 内嵌 WebView，直接操作管理面板，不用再开浏览器 |
| 底部按钮 | 一键安装 / 启动 / 停止 / 重启 / 扫码登录 / 看日志 / 状态 |

点底部按钮时，App 会通过 Termux 的 `RUN_COMMAND` 接口把命令发过去执行，
所以你不用再手打那串很长的命令。

---

## 安装

1. 到 [Releases](https://github.com/Zxin-Pro/astrbot-android-console/releases/latest) 下载 `astrbot-console.apk`
2. 手机上允许「安装未知来源应用」，装好即可

支持 **Android 5.0+（API 21+）**。

---

## 使用前：让 Termux 允许被调用

App 需要 Termux 的配合。在 **Termux** 里执行一次：

```bash
mkdir -p ~/.termux
grep -q 'allow-external-apps' ~/.termux/termux.properties 2>/dev/null \
  || echo 'allow-external-apps=true' >> ~/.termux/termux.properties
termux-reload-settings
```

> `allow-external-apps=true` 是 Termux 出于安全默认关闭的开关，
> 不打开的话 App 发的命令会被 Termux 拒绝。

然后就可以在 App 里点 **一键安装** 了（首次约 5~15 分钟）。

---

## 典型流程

```
1. 装好 Termux（F-Droid 版）+ 打开 allow-external-apps
2. 打开「AstrBot 控制台」App
3. 点【一键安装】   → 自动下载懒人包并在 Termux 里跑完整安装
4. 点【启动】       → 拉起 AstrBot + NapCat
5. 点【扫码登录】   → 按提示扫码登录 QQ
6. 切到「AstrBot 面板」→ 配置大模型 API Key，即可开聊
```

---

## 从源码构建

仓库里没有用 Gradle，而是直接用 Android SDK 自带的
`aapt2 + javac + d8 + apksigner` 构建，链路短、可控、无第三方依赖。

推送代码到 `main` 分支后，GitHub Actions 会自动：
构建 APK → 上传 artifacts → 发布到 Release（tag `latest`）。

本地构建（需已装 Android SDK）：

```bash
export ANDROID_HOME=/path/to/android-sdk
sdkmanager --install "platforms;android-34" "build-tools;34.0.0"
bash scripts/build.sh
# 产物: dist/astrbot-console.apk
```

重新生成图标：

```bash
python3 scripts/make-icons.py
```

---

## 目录结构

```
.
├── .github/workflows/build.yml   # CI：自动构建 + 发 Release
├── app/
│   ├── AndroidManifest.xml
│   ├── res/mipmap-*/             # 图标（脚本生成）
│   └── src/com/zxin/astrbotconsole/MainActivity.java
├── scripts/
│   ├── build.sh                  # 构建脚本
│   └── make-icons.py             # 图标生成
└── pack/astrbot-napcat-android.zip   # 安卓懒人包（供一键安装下载）
```

---

## 说明

- App 访问的是 **本机** `127.0.0.1` 的 6185 / 6099，不联网、不外传数据
- 已开启 `usesCleartextTraffic`，因为本机面板走 http
- 未安装 Termux 或未开启外部调用时，点按钮会**自动把命令复制到剪贴板**兜底
- NapCat 属于第三方 QQ 框架，存在账号风险，建议使用小号

---

## License

MIT
