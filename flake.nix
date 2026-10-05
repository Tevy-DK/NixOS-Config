{
  description = "DogKing's flake settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # 全局主题：颜色/字号/光标的唯一来源，system 与 home 两层共用
      theme = import ./system/theme.nix;
      # 主机清单：下面的输出全部由它自动生成
      hosts = import ./hosts/inventory.nix;
      # 用户层开关面板：嵌入与独立两条路径都必须显式提供，
      # 否则模块系统会退化为从 _module.args 解析而触发无限递归
      enabled = import ./home/modules-enables.nix;

      # 桌面环境档案：inventory 每台机器的 desktop 字段 → 用户层开关覆盖。
      # 与 modules-enables.nix 的基础面板合并（同名键以档案为准）：
      #   niri     = niri + fuzzel 启动器 + niri 的 GTK 外观（工作环境）
      #   hyprland = Hyprland + caelestia-shell，启动器用 caelestia 自带的，
      #              不装 fuzzel；GTK 外观由 caelestia theme.enableGtk 接管，
      #              niri 的 gtk.nix（adw-gtk3 + 方角描边）不能进这个环境
      #              （娱乐环境）
      # 新桌面 = home/ 与 system/ 各加一个模块 + 这里加一行档案。
      desktopProfiles = {
        niri = { niri = true; hyprland = false; caelestia = false; launcher = true; gtk = true; powermenu = true; };
        hyprland = { niri = false; hyprland = true; caelestia = true; launcher = false; gtk = false; powermenu = false; };
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
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit (cfg) system;
            overlays = [ self.overlays.default ];
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs theme enabled;
            inherit (cfg) username;
            hostname = name;
          };
          modules = [ ./home/default.nix ];
        };
    in {
      overlays.default = final: prev: {
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
      # 层级：hosts/<名字>/（主机层）+ ./system（系统层）+ ./home（用户层）。
      nixosConfigurations = builtins.mapAttrs (name: cfg:
        nixpkgs.lib.nixosSystem {
          inherit (cfg) system;
          specialArgs = {
            inherit inputs theme;
            inherit (cfg) username;
            hostname = name;
            desktop = cfg.desktop or "niri";
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
              home-manager.extraSpecialArgs = {
                inherit inputs theme;
                enabled = mkEnabled name cfg;
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
          # 用户名/架构取自清单里的第一台机器
          all = let
            first = builtins.head (builtins.attrValues hosts);
            names = builtins.filter
              (n: !(builtins.elem n [ "default" "modules-enables" ]))
              (builtins.attrNames (helpers.nixModules ./home));
            allEnabled = { enable = nixpkgs.lib.genAttrs names (_: true); };
          in mkHomeConfig "all" first allEnabled;
        };
    };
}
