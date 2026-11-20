# AGENTS.md

## Home Manager 的生效方式

- 本仓的 Home Manager 绑定在 NixOS 模块里（`useGlobalPkgs` / `useUserPackages`），
  用户环境由系统的 `home-manager-<user>.service` 激活，包在
  `/etc/profiles/per-user/<user>`。
  日常改动用 `sudo nixos-rebuild switch --flake .#<主机名>`（或 `boot`）生效。
- 独立的 `home-manager switch --flake .#<主机名>` 只用于临时验证，不要作为长期生效方式：
  它会在 `~/.local/state/nix/profiles/` 下新建独立 generation，与系统绑定的
  Home Manager 并行，可能造成遮蔽或链接打架。

## 临时测试后必须清理

1. 查看独立 generation（`home-manager` 不在 PATH 时用这条）：
   ```bash
   nix shell nixpkgs#home-manager --command home-manager generations
   ```
2. 不是当前 generation 的，按 ID 删除：
   ```bash
   home-manager remove-generations <ID>
   ```
3. 如果它就是当前/唯一的 generation（`remove-generations` 会拒绝删除当前
   generation），删掉独立 profile 的两个符号链接即可（只删链接，不要
   `rm -rf`，也不要动 `/nix/store` 里的路径）：
   ```bash
   rm ~/.local/state/nix/profiles/home-manager-<ID>-link
   rm ~/.local/state/nix/profiles/home-manager
   ```
4. 确认系统 generation 未受影响：`readlink /etc/profiles/per-user/$USER`。
