# 登录管理器：noctalia-greeter（greetd + 自带 wlroots 合成器），替代原 ly。
#
# 外观怎么跟系统统一（2026-10-25 定稿）：
#   - 颜色 / 圆角 / 壁纸 / 字体走 Noctalia Sync。shell 的调色板本来就是壁纸取色
#     （home/noctalia-config.toml 的 theme.source = "wallpaper"），Sync 把它连同
#     壁纸、shell 字体写进 /var/lib/noctalia-greeter/sync.toml，greeter 直接读。
#     所以这里**绝不能**写 [appearance.palette]：只要 greeter.toml 里有一份完整
#     palette，就会整份盖掉 Sync 的配色（src/greeter/appearance_config.cpp 的
#     loadGreeterSyncedAppearance 先看 greeter.toml）。同理 theme_mode /
#     corner_radius_scale / font_family 只在有 palette 时才从 greeter.toml 读，
#     没有 palette 时这些键是死的，不在这里写。字体不写死也不用管：greeter 默认
#     sans-serif 与 shell 的 shell.font_family 默认值（sans-serif）本来就一致，
#     以后 shell 改字体，Sync 会带过来。
#   - 壁纸只声明兜底底色（[appearance.wallpaper].fill_color）：wallpaper 的两个
#     来源按**单个键**合并、greeter.toml 优先，所以只给 fill_color 不会挡住
#     Sync 传来的 path（源码 mergeWallpaperAppearance）。首次 Sync 之前登录页
#     至少是主题底色，不是默认黑。
#   - 光标 / 键盘 / 默认 session 是确定值，声明式写死：光标与 theme.nix 同一份
#     Bibata-Modern-DK（lib/cursor-package.nix，会话里 home.pointerCursor 用它）。
#   - 首次需要在 shell 里跑一次 Sync（设置 → Security → Noctalia Greeter →
#     Sync Now，或打开 Auto-Sync）；passwordlessSyncUsers 让本人这台机器免
#     管理员认证，之后换壁纸/改配色会自动跟进。
{ config, lib, pkgs, theme, username, ... }:
let
  cursor = import ../lib/cursor-package.nix { inherit pkgs theme; };
  greeterPackage = config.services.displayManager.noctalia-greeter.package;
in
{
  services.displayManager.noctalia-greeter = {
    enable = true;

    # 光标与 theme.nix 一致；模块会据此补 settings.cursor.theme / .path
    cursorTheme = {
      package = cursor;
      name = theme.cursor-name;
    };

    # 允许本机用户把 shell 外观同步到登录页而不弹管理员认证
    passwordlessSyncUsers = [ username ];

    settings = {
      # 默认 session 用 desktop entry 的 Name=（不是 niri.desktop 这个文件名）
      session.default = "Niri";

      # 与 niri 的 input.keyboard 一致：us 布局、NumLock 开
      keyboard = {
        layout = "us";
        numlock = true;
      };

      cursor.size = theme.cursor-size;

      appearance = {
        # 钉住 Synced 方案：颜色跟 shell/壁纸走，登录页手动换 scheme 也不留存
        scheme = "Synced";
        # 仅作 Sync 之前的兜底底色；Sync 装上壁纸后 path 生效，这个值只当留白底色
        wallpaper.fill_color = theme.bg;
      };
    };
  };

  # nixpkgs 的 greeter 模块没把 NixOS 的 session 目录塞进 greeter 环境，而
  # greeter 只从 /usr/share、/run/current-system/sw/share 和 XDG_DATA_DIRS 找
  # session（nixpkgs 默认 pathsToLink 不含 wayland-sessions）。用 upstream
  # 项目 flake 模块同款的 env 包装，传入 displayManager.sessionData.desktops，
  # 否则登录页的 session 列表为空、默认 Niri 也选不中。
  services.greetd.settings.default_session.command =
    "${lib.getExe' pkgs.coreutils "env"} "
    + "XDG_DATA_DIRS=${config.services.displayManager.sessionData.desktops}/share "
    + lib.getExe' greeterPackage "noctalia-greeter-session";
}
