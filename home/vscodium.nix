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
  programs.vscodium = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        zhuangtongfa.material-theme
        ziglang.vscode-zig
        yzhang.markdown-all-in-one
        bbenoist.nix
        ms-python.python
        ms-vscode.makefile-tools
        ms-ceintl.vscode-language-pack-zh-hans
      ];
      userSettings = vscodesettings;
    };
  };
}
