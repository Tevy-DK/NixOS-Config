{
  description = "DogKing's flake settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 自建二进制包集（omp、sjmcl 等），用户级安装见 home/omp.nix、home/pkgs.nix
    tevy-dk-attic = {
      url = "github:Tevy-DK/Tevy-DK-attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # 全局主题按桌面环境选：字体/光标共享，配色各有写入者。
      # niri：运行期配色由 Noctalia 从壁纸生成，theme.nix 只供
      # fastfetch/zathura 等静态工具；hyprland：运行期配色由 Caelestia
      # 壁纸方案接管（gtk/hypr/btop + postHook 的 ghostty/cava），
      # theme-hyprland.nix 是静态兜底与 fastfetch/zathura/mpv/fzf/bat 的色源。
      themes = {
        niri = import ./system/theme.nix;
        hyprland = import ./system/theme-hyprland.nix;
      };
      themeFor = desktop:
        themes.${desktop}
          or (throw "flake.nix: 未知 desktop = \"${desktop}\"，可选：${builtins.concatStringsSep "、" (builtins.attrNames themes)}");
      # 主机清单：下面的输出全部由它自动生成
      hosts = import ./hosts/inventory.nix;
      # 用户层开关面板：嵌入与独立两条路径都必须显式提供，
      # 否则模块系统会退化为从 _module.args 解析而触发无限递归
      enabled = import ./home/modules-enables.nix;

      # 桌面环境档案：inventory 每台机器的 desktop 字段 → 用户层开关覆盖。
      # 与 modules-enables.nix 的基础面板合并（同名键以档案为准）：
      #   niri     = niri + noctalia 外壳（工作环境）
      #   hyprland = Hyprland + caelestia + clipse 剪贴板（Caelestia 壁纸配色）
      # 两个档案显式互斥，避免任一模块混入另一台机器。
      # 新桌面 = home/ 与 system/ 各加一个模块 + 这里加一行档案。
      desktopProfiles = {
        niri = {
          niri = true;
          noctalia = true;
          gtk = true;
          hyprland = false;
          caelestia = false;
          clipboard = false;
          hyprland-theme = false;
        };
        hyprland = {
          niri = false;
          noctalia = false;
          gtk = false;
          hyprland = true;
          caelestia = true;
          clipboard = true;
          hyprland-theme = true;
        };
      };

      # 单台机器最终的用户层开关 = 基础面板 // 桌面档案（desktop 缺省为 niri）
      mkEnabled = name: cfg: {
        enable = enabled.enable // desktopProfiles.${cfg.desktop or "niri"}
          or (throw "hosts/inventory.nix: 机器 ${name} 的 desktop = \"${cfg.desktop or "niri"}\" 不认识，可选：${builtins.concatStringsSep "、" (builtins.attrNames desktopProfiles)}");
      };

      helpers = import ./lib/module-discovery.nix { lib = nixpkgs.lib; };

      # 用户层独立配置的一份（enabled 决定加载哪些 home/ 模块）
      # 独立路径的 pkgs 不经过 nixosSystem，要自带 overlay 和 allowUnfree，
      # 与嵌入路径（useGlobalPkgs 共享系统 pkgs）保持一致
      mkHomeConfig = name: cfg: enabled:
        let
          desktop = cfg.desktop or "niri";
          theme = themeFor desktop;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit (cfg) system;
            overlays = [ self.overlays.default ];
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs theme enabled desktop;
            inherit (cfg) username;
            hostname = name;
          };
          modules = [ ./home/default.nix ];
        };
    in {
      # 仅保留本仓的 yazi 插件修补；omp 直接引用 tevy-dk-attic 的包，
      # 不再把第三方包集注入 pkgs 命名空间。
      overlays.default = _final: prev: {
        yaziPlugins = prev.yaziPlugins // {
          mount = prev.yaziPlugins.mount.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace mount.yazi/cross.lua \
                --replace-fail '"--no-user-interaction"' ""
            '';
          });
        };
      };

      # 多机器（借鉴 koru）：hosts/inventory.nix 每个条目自动生成一套系统。
      # 层级：hosts/<名字>/（该配置的主机层）+ ./system + ./home。
      # 同一物理机的多个桌面档案只放薄薄一层 default.nix，共享 hosts/common/。
      nixosConfigurations = builtins.mapAttrs (name: cfg:
        let
          desktop = cfg.desktop or "niri";
          theme = themeFor desktop;
          enabled = mkEnabled name cfg;
        in
        nixpkgs.lib.nixosSystem {
          inherit (cfg) system;
          specialArgs = {
            inherit inputs theme;
            inherit (cfg) username;
            hostname = name;
            inherit desktop;
          };
          modules = [
            (./. + "/hosts/${name}") # 主机层：硬件、引导、地区、账户、代理
            ./system                 # 系统层：机器无关的共享模块
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                self.overlays.default
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Hyprland 首次启动会先写自己的 hyprland.lua；HM 激活遇到
              # 普通文件时不再整体失败，而是备份到 .hm-backup 后建立链接。
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = {
                inherit inputs theme enabled desktop;
                inherit (cfg) username;
                hostname = name;
              };
              home-manager.users.${cfg.username} = import ./home/default.nix;
            }
          ];
        }) hosts;

      # 用户层独立开关（不用重建系统）：home-manager switch --flake .#<主机名>
      homeConfigurations =
        builtins.mapAttrs
          (name: cfg: mkHomeConfig name cfg (mkEnabled name cfg))
          hosts // {
          # 全模块强制开启版，用于求值检查（借鉴 koru homeConfigurations.all）
          # 用户名/架构取自 desktop-niri；主题固定 hyprland 超集。
          all = let
            first = hosts.desktop-niri;
            allCfg = first // { desktop = "hyprland"; };
            names = builtins.filter
              (n: !(builtins.elem n [ "default" "modules-enables" ]))
              (builtins.attrNames (helpers.nixModules ./home));
            allEnabled = { enable = nixpkgs.lib.genAttrs names (_: true); };
          in mkHomeConfig "all" allCfg allEnabled;
        };
    };
}
