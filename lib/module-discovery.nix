# 借鉴 koru lib/module-discovery.nix：枚举目录直属的 .nix 模块。
# 目前只服务于 home/default.nix 的开关面板校验；嵌套目录里的东西
# （如 home/nvim/、home/cava-config/）由所属模块自己引用，不参与发现。
{ lib }:
rec {
  # dir 下直属的 *.nix 文件，按文件名排序，以路径列表返回。
  nixFiles =
    dir:
    map (n: dir + "/${n}") (
      builtins.attrNames (
        lib.filterAttrs (n: type: type == "regular" && lib.hasSuffix ".nix" n) (builtins.readDir dir)
      )
    );

  # 同上，但以 模块名（去掉 .nix 后缀）-> 路径 的 attrset 返回。
  nixModules =
    dir:
    lib.listToAttrs (
      map (p: lib.nameValuePair (lib.removeSuffix ".nix" (baseNameOf p)) p) (nixFiles dir)
    );
}
