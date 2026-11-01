{ config, lib, pkgs, ...}:
let
  # starship 的 fish 集成启动时会把 `command -v starship` 解析到的绝对路径
  # 写死进 fish_prompt/fish_right_prompt。PATH 中 ~/.nix-profile/bin 排在
  # 系统 profile 之前，而 home-manager 激活会重写该 profile（useUserPackages
  # 的新一代可能不再包含 bin/），于是激活前打开的 shell 在 nrs 之后提示
  # "未知的命令：/home/dk/.nix-profile/bin/starship"。
  # 改为构建时用 store 里的 starship 生成完整初始化脚本，提示符不再依赖
  # 可变的 profile 路径。
  starship = config.programs.starship.package;
  starshipFishInit = pkgs.runCommandLocal "starship-fish-init" { } ''
    PATH=${lib.makeBinPath [ starship ]} \
      ${lib.getExe starship} init fish --print-full-init > "$out"
  '';
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.fish.interactiveShellInit = ''
    if test "$TERM" != dumb
      source ${starshipFishInit}
    end
  '';
  xdg.configFile."starship.toml".text = ''
"$schema" = 'https://starship.rs/config-schema.json'

[aws]
symbol = " "

[azure]
symbol = " "

[battery]
full_symbol = "󰁹 "
charging_symbol = "󰂄 "
discharging_symbol = "󰂃 "
unknown_symbol = "󰂑 "
empty_symbol = "󰂎 "

[buf]
symbol = " "

[bun]
symbol = " "

[c]
symbol = " "

[cpp]
symbol = " "

[cmake]
symbol = " "

[cobol]
symbol = " "

[conda]
symbol = " "

[container]
symbol = " "

[crystal]
symbol = " "

[dart]
symbol = " "

[deno]
symbol = " "

[direnv]
symbol = " "

[directory]
read_only = " 󰌾"

[docker_context]
symbol = " "

[dotnet]
symbol = " "

[elixir]
symbol = " "

[elm]
symbol = " "

[erlang]
symbol = " "

[fennel]
symbol = " "

[fortran]
symbol = " "

[fossil_branch]
symbol = " "

[gcloud]
symbol = "󱇶 "

[gleam]
symbol = " "

[git_branch]
symbol = " "

[git_commit]
tag_symbol = '  '

[golang]
symbol = " "

[gradle]
symbol = " "

[guix_shell]
symbol = " "

[haskell]
symbol = " "

[haxe]
symbol = " "

[helm]
symbol = " "

[hg_branch]
symbol = " "

[hostname]
ssh_symbol = " "

[java]
symbol = " "

[julia]
symbol = " "

[kotlin]
symbol = " "

[kubernetes]
symbol = "󱃾 "

[lua]
symbol = " "

[maven]
symbol = " "

[memory_usage]
symbol = "󰍛 "

[meson]
symbol = "󰔷 "

[mojo]
symbol = "󰈸 "

[nats]
symbol = " "

[netns]
symbol = "󰛳 "

[nim]
symbol = " "

[nix_shell]
symbol = " "

[nodejs]
symbol = " "

[ocaml]
symbol = " "

[odin]
symbol = "󰟢 "

[opa]
symbol = " "

[openstack]
symbol = " "

[os.symbols]
AIX = " "
AlmaLinux = " "
Alpaquita = " "
Alpine = " "
ALTLinux = " "
Amazon = " "
Android = " "
AOSC = " "
Arch = " "
Artix = " "
Bluefin = " "
CachyOS = " "
CentOS = " "
Debian = " "
DragonFly = " "
Elementary = " "
Emscripten = " "
EndeavourOS = " "
Fedora = " "
FreeBSD = " "
Garuda = " "
Gentoo = " "
HardenedBSD = "󰞌 "
Illumos = " "
InstantOS = " "
Ios = "󰀷 "
Kali = " "
Linux = " "
Mabox = " "
Macos = " "
Manjaro = " "
Mariner = " "
MidnightBSD = " "
Mint = " "
NetBSD = " "
NixOS = " "
Nobara = " "
OpenBSD = " "
OpenCloudOS = " "
openEuler = " "
openSUSE = " "
OracleLinux = "󰺡 "
PikaOS = " "
Pop = " "
Raspbian = " "
Redhat = "󱄛 "
RedHatEnterprise = "󱄛 "
Redox = "󰀘 "
RockyLinux = " "
Solus = " "
SUSE = " "
Ubuntu = " "
Ultramarine = " "
Unknown = " "
Uos = " "
Void = " "
Windows = "󰍲 "
Zorin = " "

[package]
symbol = "󰏗 "

[perl]
symbol = " "

[php]
symbol = " "

[pijul_channel]
symbol = " "

[pixi]
symbol = "󰏗 "

[pulumi]
symbol = " "

[purescript]
symbol = " "

[python]
symbol = " "

[raku]
symbol = "󱖊 "

[red]
symbol = "󱍼 "

[rlang]
symbol = "󰟔 "

[ruby]
symbol = " "

[rust]
symbol = "󱘗 "

[scala]
symbol = " "

[shlvl]
symbol = "󰹍 "

[singularity]
symbol = " "

[solidity]
symbol = " "

[spack]
symbol = " "

[status]
symbol = " "

[sudo]
symbol = " "

[swift]
symbol = " "

[terraform]
symbol = " "

[vlang]
symbol = " "

[typst]
symbol = " "

[vagrant]
symbol = " "

[xmake]
symbol = " "

[zig]
symbol = " "
  '';
}
