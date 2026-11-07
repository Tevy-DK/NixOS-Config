{ config, ... }:
{
  # 用户层 distrobox 配置；distrobox 本体由 system/podman.nix 安装到系统 PATH。
  programs.distrobox = {
    enable = true;
    package = null;
    # 容器手动用 distrobox assemble create 创建；不启用登录时自动拉取/重建。
    enableSystemdUnit = false;

    settings = {
      # 新建容器的默认镜像与名称
      container_image_default = "fedora:45";
      container_name_default = "fedora-45";
      # 共享宿主 HOME。distrobox 默认也会挂载，这里显式声明避免被其他配置覆盖。
      container_user_custom_home = "$HOME";
    };

    # 声明式容器清单：distrobox assemble create 时按此创建。
    containers = {
      fedora-45 = {
        image = "fedora:45";
        # 与宿主共享 /home/dk，而不是容器内独立 home
        home = config.home.homeDirectory;
        # 已有容器不自动替换，避免升级清单时丢数据
        replace = false;
      };
    };
  };
}
