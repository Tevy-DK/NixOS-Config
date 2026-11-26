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
    package = pkgs.vscode-fhs;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        zhuangtongfa.material-theme # One Dark Pro Night Flat
        ziglang.vscode-zig # ziglang support
        yzhang.markdown-all-in-one # markdown support
        bbenoist.nix # nix support  
        ms-python.python # python support
        ms-vscode.makefile-tools # makefile support
        ms-ceintl.vscode-language-pack-zh-hans # Chinese language pack
        ms-vscode.cpptools # C/C++ support 
      ];
      mutableUserSettings = true;
      userSettings = vscodesettings;
    };
  };
}
