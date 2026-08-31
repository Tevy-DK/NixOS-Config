{ pkgs, config, ... }:

let
  vscodesettings = {
    "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";
    "terminal.integrated.fontSize" = 15;
    "security.workspace.trust.untrustedFiles" = "open";
    "editor.fontSize" = 18;
    "editor.fontFamily" = "FiraCode Nerd Font Mono,FiraCode Nerd Font Mono Med";
    "workbench.colorTheme" = "One Dark Pro Night Flat";
    "files.autoSave" = "afterDelay";
    "chat.disableAIFeatures" = true;
    "liveServer.settings.donotShowInfoMsg" = true;
    "explorer.confirmDelete" = false;
    "zig.zls.enabled" = "on";
  };

in {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;   # 使用 VSCodium（轻量替代品）
    extensions = with pkgs.vscode-extensions; [
      vscode-extensions.zhuangtongfa.material-theme
      vscode-extensions.ziglang.vscode-zig
      yzhang.markdown-all-in-one
      vscode-extensions.bbenoist.nix
      ms-python.python
      ms-vscode.makefile-tools

    ];
    userSettings = vscodesettings;
  };
}