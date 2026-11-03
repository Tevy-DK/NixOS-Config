# --- flatpak ---
# Flatpak 沙箱与 NixOS 的目录布局不兼容：宿主光标/主题都在 /nix/store，
# 而沙箱默认只暴露 /run/host/user-share/icons 和 /run/host/share/icons，
# 且 /nix/store 只有被显式 mount 的路径。结果是：
#   - 光标别名与 adw-gtk3 主题在沙箱里是断链；
#   - GTK 应用通过 portal 拿到宿主 adw-gtk3(-dark) 名称却找不到主题文件。
# 全局 override 只补这两块：
#   1. filesystems 暴露光标包、adw-gtk3、Tela 图标包和 ~/.themes；
#   2. XCURSOR_* 固定到原版 Bibata Modern Ice，XCURSOR_PATH 先指向光标包
#      本体，再回落到宿主 share。GTK 主题名不写死：仍由 portal 从宿主
#      GSettings 读取，避免把沙箱里的深浅模式锁死。
{ lib, pkgs, theme, ... }:
let
  cursorPackage = pkgs.bibata-cursors;
  tela = pkgs.tela-icon-theme;
  adw = pkgs.adw-gtk3;

  filesystems = lib.concatStringsSep ";" [
    "${cursorPackage}:ro"
    "${adw}:ro"
    "${tela}:ro"
    "~/.themes:ro"
  ];

  # Flatpak X11 应用走 XIM；沙箱里没有 fcitx 的 GTK/Qt 模块，但 XIM server
  # 在宿主 XWayland 上，明确传入避免依赖启动环境的继承。
  override = ''
    [Context]
    filesystems=${filesystems};

    [Environment]
    XCURSOR_THEME=${theme.cursor-name}
    XCURSOR_SIZE=${toString theme.cursor-size}
    XCURSOR_PATH=${cursorPackage}/share/icons:/run/host/user-share/icons:/run/host/share/icons
    XMODIFIERS=@im=fcitx
  '';
in
{
  # 用户级全局 override；per-app override 仍优先。flatpak 只读该文件，
  # 需要改配置时改本仓库再重建，不要在运行时用 `flatpak override --user`
  # 覆写这个 store 软链。
  xdg.dataFile."flatpak/overrides/global".text = override;

  # GTK 在沙箱内外都会查 ~/.themes；直接链到 store，避免经过
  # home-manager-files 中间层（否则 flatpak 还要额外暴露那一层）。
  home.activation.flatpakThemeLinks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.themes"
    ln -sfn ${lib.escapeShellArg "${adw}/share/themes/adw-gtk3"} "$HOME/.themes/adw-gtk3"
    ln -sfn ${lib.escapeShellArg "${adw}/share/themes/adw-gtk3-dark"} "$HOME/.themes/adw-gtk3-dark"
  '';

  # Tela 图标包在 profile 里，flatpak 看不到；只在缺失时补链，
  # 不覆盖用户已有的 ~/.local/share/icons/Tela* 实体目录。
  home.activation.flatpakIconLinks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.local/share/icons"
    for theme in Tela Tela-dark Tela-light; do
      link="$HOME/.local/share/icons/$theme"
      if [ ! -e "$link" ] && [ ! -L "$link" ]; then
        ln -s ${tela}/share/icons/"$theme" "$link"
      fi
    done
  '';
}
