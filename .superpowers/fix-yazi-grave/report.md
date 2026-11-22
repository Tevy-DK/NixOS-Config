# fix-yazi-grave 报告

日期：2026-11-21
提交：`d6531e7`（main，已推送）

## 根因

Ghostty 1.4.0 在 Hyprland ≥0.56 上，对 `global:` 键位改用原生
`vicinae-hotkey-v1` 协议注册（`ghostty +show-config --docs` 的 global 说明；
Hyprland 0.57.2 二进制里含 `vicinae_hotkey_v1` 与该告警字符串）。

`home/ghostty.nix` 里的 `global:ctrl+grave_accent=toggle_quick_terminal`
会让**每个 ghostty 进程**各自注册同一个全局触发键。`gtk-single-instance`
为默认 `detect` 时，`ghostty -e yazi`（Hyprland Mod+E）带 CLI 参数启动，
被判为独立实例 → 第二个实例再注册 `Ctrl+Grave` 时，Hyprland 的
vicinae-hotkey 管理器拒绝重复触发键，Ghostty 弹出
`Ctrl+Grave: the trigger is already bound by another hotkey`。
不是 Hyprland 自身的 `ctrl+grave` 绑定冲突（hyprland.lua 里原本没有该绑定）。

## 修复（最小改动）

1. `home/ghostty.nix:100-105`：删除 `global:ctrl+grave_accent=...`，
   原地留注释说明原因与替代方案；其余 keybind 全部未动。
2. `home/hyprland.lua:315-318`：新增
   `hl.bind("CTRL + grave", hl.dsp.exec_cmd("ghostty +toggle-quick-terminal"))`。

`+toggle-quick-terminal` 是 Ghostty 1.4.0 真实存在的 CLI action
（`ghostty +help` 列出；`+list-actions` 亦含 `toggle_quick_terminal`），
仅 GTK 支持，经 D-Bus 找 `com.mitchellh.ghostty` 实例；包内自带
`share/dbus-1/services/com.mitchellh.ghostty.service`
（`Exec=... --gtk-single-instance=true --initial-window=false`），
所以没有实例时也能由 D-Bus 激活。实测执行该命令后 Hyprland 出现
`ghostty-quick-terminal` 层（pid 11427），说明切换生效。

## 验证

- `nix build .#homeConfigurations.desktop-hyprland.activationPackage --no-link` → exit 0
- 生成的 `home-files/.config/ghostty/config`（`rzm7nsh...`）中 `global:` 行已消失，
  `keybind` 仅剩到 `ctrl+shift+comma`；`validate-config` 通过。
- `ghostty +validate-config --config-file=<生成config>` → exit 0
- 生成的 `home-files/.config/hypr/config.lua:318` 含 `CTRL + grave` 绑定
- `luac -p home/hyprland.lua` → exit 0
- `git diff --check` → exit 0

## AGENTS.md（新增）

`/etc/nixos/AGENTS.md`：说明本仓 HM 由 NixOS 模块绑定
（`useGlobalPkgs`/`useUserPackages`，包在 `/etc/profiles/per-user/<user>`），
独立 `home-manager switch` 仅作临时验证；测试后清理独立 generation，
命令用真实的 `home-manager generations` / `home-manager remove-generations <ID>`
（注：`remove-generations` 是复数；且拒绝删除当前 generation）。
当前/唯一 generation 的安全清理是删除两个 profile 符号链接
（`home-manager-<ID>-link`、`home-manager`），不删 store 路径、不 `rm -rf`。

## 独立 HM generation 清理

`~/.local/state/nix/profiles/home-manager` → `home-manager-1-link`
→ `wmfw4z0f9...-home-manager-generation`，生成时间 2026-11-20 22:21:57，
是独立 HM 的 generation（系统 HM 的 `home.path` 为 `4zy8b...`，两者不同；
21:26 后编辑 ghostty.nix、22:21 由 agent shell 触发的测试留下）。
它是唯一且当前 generation，`remove-generations` 会拒绝，故按安全方式删除：

```
rm ~/.local/state/nix/profiles/home-manager-1-link ~/.local/state/nix/profiles/home-manager
```

清理前已确认系统侧未变：`/etc/profiles/per-user/dk -> /etc/static/profiles/per-user/dk`、
`~/.config/ghostty/config -> mr6l50v3...-home-manager-files`、`~/.nix-profile` 未动；
清理后复核仍然一致。store 路径保留（GC 前可恢复）。
今日（11-21）没有新增的独立 generation，只有上述 11-20 22:21 的遗留。

## 推送

```
To ssh://ssh.github.com:443/Tevy-DK/NixOS-Config.git
   ebb9bdd..d6531e7  main -> main
```

（fast-forward，remote 之前落后 11 个本地提交，一并发布；未 force/amend/rebase。）

## 线上应用（2026-11-21 07:19–07:21，无 sudo）

- toplevel：`/nix/store/26xmawdhw10vg4fvc2fxdxwvmbh8hlc7-nixos-system-desktop-hyprland-...`
- HM generation：`/nix/store/vv8g4p9fsfgcgwzz27av7ijpll16x0b7-home-manager-generation`，
  用 `hm-setup-env <generation>`（driver-version 1，不建 profile）激活 → exit 0。
- `~/.config/ghostty/config` → `0kskvwbr...-home-manager-files`：无 `global:`，
  keybind 末行为 `ctrl+shift+comma=reload_config`，无 quick 绑定；
  `ghostty +validate-config --config-file=$HOME/.config/ghostty/config` → 0。
- `~/.config/hypr/config.lua` 同 store，第 318 行为 `CTRL + grave`。
- `hyprctl reload` → ok；`hyprctl binds -j`：modmask 4（CTRL）、key `grave`、
  dispatcher `exec_cmd`。
- `ghostty +toggle-quick-terminal` 开→出现 `ghostty-quick-terminal` 层，再→关闭（0 层）。
- `ghostty -e true` exit 0，stderr/journal/hyprland.log 均无
  `trigger is already bound` / `Ctrl+Grave`。
- `~/.local/state/nix/profiles/` 仍只有 `profile*`；`~/.nix-profile`、
  `/etc/profiles/per-user/dk` 未变；仅 `.superpowers/` 为 untracked，未提交未推送。

## 遗留

- Hyprland 新绑定需下次 `nixos-rebuild switch/boot` 或重载 Lua 配置后生效（按任务要求未执行）。
- 未改动 niri 机器的配置。
