{ config, pkgs, ... }:
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    openssl
    stdenv.cc.cc.lib  # 提供 libstdc++.so.6
    zlib
    libffi
    glibc
    sqlite
  ];
}
