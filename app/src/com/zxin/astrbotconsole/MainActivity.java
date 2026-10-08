package com.zxin.astrbotconsole;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

/**
 * AstrBot + NapCat 安卓控制台。
 *
 * 把「手机本地跑 AstrBot + NapCat」这条链路的日常操作收进一个 App：
 *   - 内嵌 AstrBot / NapCat 管理面板（本机 6185 / 6099）
 *   - 一键调用 Termux 执行安装、启动、停止、重启、登录、看日志
 *
 * 依赖 Termux 的 RUN_COMMAND 外部调用能力：
 *   Termux 中需设置 ~/.termux/termux.properties:  allow-external-apps=true
 */
public class MainActivity extends Activity {

    /** 懒人包下载地址（仓库内自带） */
    private static final String PACK_URL =
            "https://raw.githubusercontent.com/Zxin-Pro/astrbot-android-console/main/pack/astrbot-napcat-android.zip";
    /** 国内加速镜像（优先） */
    private static final String PACK_MIRROR = "https://ghfast.top/" + PACK_URL;

    private static final String ASTRBOT_URL = "http://127.0.0.1:6185";
    private static final String NAPCAT_URL = "http://127.0.0.1:6099";

    private static final String CMD_INSTALL =
            "cd ~ && pkg install -y unzip curl >/dev/null 2>&1; "
            + "(curl -fsSL '" + PACK_MIRROR + "' -o pack.zip"
            + " || curl -fsSL '" + PACK_URL + "' -o pack.zip)"
            + " && unzip -o pack.zip >/dev/null"
            + " && bash astrbot-napcat-android/install.sh";

    private WebView web;
    private TextView status;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(Color.parseColor("#0f1216"));

        // ---------- 状态栏 ----------
        status = new TextView(this);
        status.setTextColor(Color.parseColor("#8ab4f8"));
        status.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        status.setPadding(dp(14), dp(10), dp(14), dp(10));
        status.setText("就绪 · 等待面板加载");
        root.addView(status, new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        // ---------- 面板切换 ----------
        root.addView(makeRow(new String[][]{
                {"AstrBot 面板", "panel:" + ASTRBOT_URL},
                {"NapCat 面板", "panel:" + NAPCAT_URL},
                {"刷新", "cmd:__refresh__"},
        }));

        // ---------- WebView ----------
        web = new WebView(this);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setUseWideViewPort(true);
        s.setLoadWithOverviewMode(true);
        s.setBuiltInZoomControls(true);
        s.setDisplayZoomControls(false);
        web.setBackgroundColor(Color.parseColor("#0f1216"));
        web.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                setStatus("已加载 · " + url);
            }

            @Override
            public void onReceivedError(WebView view, int code, String desc, String url) {
                setStatus("连接失败 · 服务可能未启动（bash abot start）");
            }
        });
        root.addView(web, new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));

        // ---------- 运维操作 ----------
        root.addView(makeRow(new String[][]{
                {"一键安装", "cmd:" + CMD_INSTALL},
                {"启动", "cmd:bash ~/astrbot-napcat/abot start"},
                {"停止", "cmd:bash ~/astrbot-napcat/abot stop"},
                {"重启", "cmd:bash ~/astrbot-napcat/abot restart"},
                {"扫码登录", "cmd:bash ~/astrbot-napcat/abot login"},
                {"看日志", "cmd:bash ~/astrbot-napcat/abot logs"},
                {"状态", "cmd:bash ~/astrbot-napcat/abot status"},
        }));

        setContentView(root);
        web.loadUrl(ASTRBOT_URL);
    }

    // ============================================================
    //  UI 构造
    // ============================================================

    private View makeRow(String[][] items) {
        HorizontalScrollView scroller = new HorizontalScrollView(this);
        scroller.setHorizontalScrollBarEnabled(false);
        scroller.setBackgroundColor(Color.parseColor("#151a20"));

        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setPadding(dp(8), dp(6), dp(8), dp(6));

        for (int i = 0; i < items.length; i++) {
            final String label = items[i][0];
            final String action = items[i][1];
            Button btn = new Button(this);
            btn.setText(label);
            btn.setAllCaps(false);
            btn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
            btn.setPadding(dp(14), dp(4), dp(14), dp(4));
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.setMargins(dp(4), 0, dp(4), 0);
            btn.setLayoutParams(lp);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onAction(label, action);
                }
            });
            row.addView(btn);
        }
        scroller.addView(row);
        return scroller;
    }

    private void onAction(String label, String action) {
        if (action.startsWith("panel:")) {
            String url = action.substring(6);
            setStatus("正在加载 " + url + " ...");
            web.loadUrl(url);
        } else if (action.startsWith("cmd:")) {
            String cmd = action.substring(4);
            if ("__refresh__".equals(cmd)) {
                setStatus("刷新中 ...");
                web.reload();
                return;
            }
            setStatus("已发送到 Termux：" + label);
            runInTermux(cmd);
        }
    }

    // ============================================================
    //  Termux 联动
    // ============================================================

    private void runInTermux(String cmd) {
        Intent i = new Intent();
        i.setClassName("com.termux", "com.termux.app.RunCommandService");
        i.setAction("com.termux.RUN_COMMAND");
        i.putExtra("com.termux.RUN_COMMAND_PATH",
                "/data/data/com.termux/files/usr/bin/bash");
        i.putExtra("com.termux.RUN_COMMAND_ARGUMENTS", new String[]{"-c", cmd});
        i.putExtra("com.termux.RUN_COMMAND_WORKDIR",
                "/data/data/com.termux/files/home");
        // background=true 不弹终端；安装/日志这类需要看到输出的用前台会话
        boolean bg = !(cmd.contains("install.sh") || cmd.contains("abot logs"));
        i.putExtra("com.termux.RUN_COMMAND_BACKGROUND", bg);
        i.putExtra("com.termux.RUN_COMMAND_COMMAND_LABEL", "AstrBot");
        try {
            startService(i);
        } catch (Exception e) {
            copyToClipboard(cmd);
            toast("未检测到可用的 Termux，命令已复制到剪贴板");
            setStatus("已复制命令 · 请到 Termux 粘贴执行");
        }
    }

    private void copyToClipboard(String text) {
        try {
            ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
            if (cm != null) cm.setPrimaryClip(ClipData.newPlainText("AstrBot", text));
        } catch (Exception ignored) {
        }
    }

    private void toast(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_LONG).show();
    }

    private void setStatus(String msg) {
        if (status != null) status.setText(msg);
    }

    private int dp(int v) {
        return (int) (v * getResources().getDisplayMetrics().density + 0.5f);
    }

    @Override
    public void onBackPressed() {
        if (web != null && web.canGoBack()) {
            web.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
