{ ... }:

{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop"; # 替换为你使用的文件管理器
      };
    };
  };
}
