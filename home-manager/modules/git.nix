{ ...}:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Godog_1145";                              # 替换 1
        email = "Godog_1145@users.noreply.gitcode.com";      # 替换 2：填真实邮箱，别再留占位符
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}