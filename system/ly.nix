# --- 系统层 ly ---
# 只在 inventory 里 desktop = "hyprland" 的机器上由 system/default.nix 导入。
# niri 机器用 noctalia-greeter（system/greeter.nix），两者互斥，不会同时注册
# display-manager。
{ ... }:

{
  services.displayManager.ly = {
    enable = true;

    settings = {
      # 直接进 Hyprland。ly 1.5 已没有 hide_session_selection 选项；
      # start_cmd 仍覆盖会话启动命令，登录后不会经 shell 会话。
      start_cmd = "start-hyprland";

      # 登录页黑洞动画：官方 ly-community 的 .dur（一颗行星被黑洞吞噬），
      # 40 帧 12fps 256 色。240x67 恰好铺满 1080p TTY 整屏；其他分辨率居中、
      # 多余部分留黑。
      # https://codeberg.org/fairyglade/ly-community/src/branch/main/animations/dur
      animation = "dur_file";
      dur_file_path = "/etc/ly/blackhole-smooth-240x67.dur";
      dur_offset_alignment = "center";

      # ly 1.4.1 的旧配置迁移启发式：config.ini 里若既没有 full_color 也没有
      # 任何颜色键（bg/fg/...），就认定这是真彩色出现前的老配置并强制
      # full_color=false，256 色 .dur 随即报 InvalidColorFormat，ly 在画登录框
      # 前直接退出。显式写 true 关掉该启发式（upstream 默认本就是 true）。
      full_color = true;
    };
  };

  environment.etc."ly/blackhole-smooth-240x67.dur".source =
    ./ly/blackhole-smooth-240x67.dur;
}
