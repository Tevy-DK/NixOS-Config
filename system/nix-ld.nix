{ config, pkgs, ... }:
{
  programs.nix-ld.enable = true;
  # nix-ld 只接管 64 位 ELF 的 /lib64/ld-linux-x86-64.so.2；
  # 32 位二进制（少数老游戏、32 位 AppImage）仍需 steam-run / FHS 环境。
  # 清单来源：nixpkgs 的 nix-ld 模块默认集、steam-run 的 FHS 库、
  # NixOS Wiki 的实践列表；某个新程序报缺库时，用 nix-index 按 soname 查补。
  # 注意：nixpkgs 模块还会追加它自带的默认库（zlib/openssl/curl/systemd 等），
  # 与本清单有重叠，buildEnv 会合并重复项，不影响使用。
  programs.nix-ld.libraries = with pkgs; [
    # 基础 C/C++ 运行时与系统库
    glibc
    stdenv.cc.cc.lib      # libstdc++.so.6 / libgcc_s.so.1
    zlib
    bzip2
    xz
    zstd
    lz4                   # liblz4.so.1
    libffi
    ncurses
    readline
    libxcrypt             # libcrypt.so.2
    libxcrypt-legacy      # libcrypt.so.1，老程序硬依赖
    expat
    icu
    libxml2
    openssl
    curl
    sqlite
    dbus
    util-linux            # libuuid.so.1
    systemd               # libudev.so.1 / libsystemd.so.0
    elfutils              # libelf.so.1 / libdw.so.1
    attr                  # libattr.so.1
    acl                   # libacl.so.1
    libssh
    libsodium

    # 图形 / GL / Vulkan
    libglvnd              # libGL.so.1 / libEGL.so.1 / libGLX.so.0 分发层
    mesa                  # GLX/EGL 实现与 mesa 驱动
    libgbm                # libgbm.so.1，Electron/Wayland 需要
    vulkan-loader         # libvulkan.so.1
    libdrm
    libva                 # libva.so.2，浏览器/播放器硬解
    wayland
    libxkbcommon

    # X11
    libX11
    libxcb
    libXext
    libXrender
    libXrandr
    libXi
    libXcursor
    libXfixes
    libXcomposite
    libXdamage
    libXtst
    libXScrnSaver         # libXss.so.1，Chromium/Electron 需要
    libxshmfence
    libXxf86vm
    libXinerama
    libXmu
    libXt
    libSM
    libICE
    libXft

    # Qt6 xcb 平台插件的直接依赖
    libxcb-cursor
    libxcb-wm
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    krb5                  # libgssapi_krb5.so.2

    # 字体 / GTK / 无障碍
    freetype
    fontconfig
    harfbuzz
    fribidi               # libfribidi.so.0，双向文本整形
    cairo
    pango
    gdk-pixbuf
    librsvg               # librsvg-2.so.2，gdk-pixbuf 的 SVG 加载
    glib
    gtk3
    gtk4                  # libgtk-4.so.1
    at-spi2-core          # 同时提供 atk / at-spi2-atk

    # 音频 / 输入 / 游戏
    alsa-lib
    libpulseaudio
    pipewire              # libpipewire-0.3.so.0，屏幕共享/捕获
    libusb1
    SDL2

    # 浏览器 / Electron 常见依赖
    nss
    nspr
    cups
    libcap

    # 图像编解码（很多预编译程序 dlopen）
    libpng
    libjpeg
    libtiff
    libwebp               # libwebp.so.7，图像代码常 dlopen
  ];
}
