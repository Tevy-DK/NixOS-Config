{ ...}:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Godog_1145";
        email = "261724093+Tevy-DK@users.noreply.github.com.";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}