{ pkgs, config, theme, ... }:

let
  vscodesettings = {
    "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";
    "terminal.integrated.fontSize" = 15;
    "security.workspace.trust.untrustedFiles" = "open";
    "editor.fontSize" = 18;
    "editor.fontFamily" = "FiraCode Nerd Font Mono,FiraCode Nerd Font Mono Med";
    "workbench.colorTheme" = "One Dark Pro Night Flat";
    # 背景统一走全局主题：One Dark Pro 只负责语法色，窗口各面背景对齐 theme.nix，
    # 作用域限定在该主题内，换主题不会被污染
    "workbench.colorCustomizations" = {
      "[One Dark Pro Night Flat]" = {
        "editor.background" = theme.bg;
        "editor.lineHighlightBackground" = theme.bg-alt;
        "editor.selectionBackground" = theme.accent-bg;
        "editorGroupHeader.tabsBackground" = theme.bg-alt;
        "tab.activeBackground" = theme.bg;
        "tab.inactiveBackground" = theme.bg-alt;
        "activityBar.background" = theme.bg;
        "sideBar.background" = theme.bg;
        "panel.background" = theme.bg;
        "terminal.background" = theme.bg;
        "titleBar.activeBackground" = theme.bg;
        "titleBar.inactiveBackground" = theme.bg-alt;
        "statusBar.background" = theme.bg-alt;
        "statusBar.noFolderBackground" = theme.bg-alt;
        "minimap.background" = theme.bg;
        "input.background" = theme.bg-alt;
        "dropdown.background" = theme.bg-alt;
        "menu.background" = theme.bg;
        "quickInput.background" = theme.bg-alt;
      };
    };
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
