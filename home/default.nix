# 用户层入口（借鉴 koru home/default.nix）。
#
# home/modules-enables.nix 是唯一开关面板：一个布尔对应 home/ 下一个
# <名字>.nix 模块，同时也是"用户层能装什么"的完整清单。面板与目录
# 双向断言，求值期直接报错而不是静默忽略：
#   - 模块文件存在但面板没登记      → unlisted
#   - 面板登记了不存在的模块        → unknown
#   - 开关写成了非布尔值            → 必须是布尔值
# 新增软件 = 加 home/<软件>.nix + 在面板登记一行，漏一步都会失败。
{
  lib,
  username,
  enabled ? import ./modules-enables.nix,
  ...
}:

let
  helpers = import ../lib/module-discovery.nix { inherit lib; };
  control = [
    "default"
    "modules-enables"
  ];
  modules = lib.filterAttrs (n: _: !(builtins.elem n control)) (helpers.nixModules ./.);

  allFiles = builtins.attrNames modules;
  flags = builtins.attrNames (enabled.enable or { });

  invalidFlags = builtins.filter (n: !(builtins.isBool enabled.enable.${n})) flags;

  # 双向漂移：逐个点名哪个文件没登记、哪个登记没有文件
  drift =
    map (n: "unlisted ${n}") (builtins.filter (n: !(builtins.elem n flags)) allFiles)
    ++ map (n: "unknown ${n}") (builtins.filter (n: !(builtins.elem n allFiles)) flags);

  selected =
    assert lib.assertMsg (invalidFlags == [ ])
      "home/modules-enables.nix: 开关必须是布尔值: ${lib.concatStringsSep ", " invalidFlags}";
    assert lib.assertMsg (drift == [ ])
      "home/modules-enables.nix 与 home/ 不一致: ${lib.concatStringsSep ", " drift}";
    builtins.filter (n: enabled.enable.${n} or false) allFiles;
in
{
  imports = map (n: modules.${n}) selected;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
