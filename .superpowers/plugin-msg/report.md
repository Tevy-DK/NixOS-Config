# borders-plus-plus 启动提示调查与修复

## 1. 确切消息与来源（hyprland 0.57.2）

- 可见消息：`[borders-plus-plus] Initialized successfully!`（5 秒 Hyprland 通知/Toast）。
- 来源：插件自身，不是 Hyprland 的重复加载报错。
  - 插件源码 `/nix/store/9szxd4sjzkpgjy7bsw776fmcyr3rdfx6-source/borders-plus-plus/main.cpp:75`：
    `HyprlandAPI::addNotification(PHANDLE, "[borders-plus-plus] Initialized successfully!", CHyprColor{0.2, 1.0, 0.2, 1.0}, 5000);`
  - 反汇编确认 `pluginInit` 中两处 `addNotification` 调用：成功分支（对应上述字符串）与版本不匹配分支。
- 排除重复加载：Hyprland 的错误文本是 `[PluginSystem] Cannot load a plugin twice!`（`src/plugins/PluginSystem.cpp:69`），并会经 `updateConfigPlugins` 变成 “Failed to load plugin …” 通知。
  - 生成配置中只有一行加载：
    `hl.plugin.load("/nix/store/1vgw09l5pxnryd2zan3higmfarg3gwzz-borders-plus-plus-0.57.0/lib/libborders-plus-plus.so")`
  - `hyprctl plugin list` 只有 1 个实例；`hyprctl repl 'return #hl.get_loaded_plugins()'` 返回 `1`。
  - 当前日志、journal（system/user）均无 `PluginSystem` / `Cannot load a plugin twice` 记录。
  - HM 渲染逻辑只按 `plugins` 列表各写一行（home-manager `modules/services/window-managers/hyprland/lib.nix:132`）；`config.lua`（仓库 `home/hyprland.lua`）不含加载语句。

## 2. 根因

插件 `PLUGIN_INIT` 每次成功初始化都无条件发一条成功通知，没有配置项可关闭，因此每次 Hyprland 启动（以及首次插件加载/重载）都会弹一次。并非重复 `plugin.load`。

## 3. 修复

- `home/hyprland.nix:5-17`：新增 `borders-plus-plus` 包覆盖，用 `postPatch` 的 `substituteInPlace` 删除 `main.cpp:75` 的成功 `addNotification` 调用；保留版本不匹配的错误通知。
- `home/hyprland.nix:24`：HM `plugins` 改用覆盖后的包。
- 插件本体功能、`home/hyprland.lua` 的 `plugin.borders_plus_plus` 边框配置不变。

## 4. 验证

- `nix build .#homeConfigurations.desktop-hyprland.activationPackage --no-link` → exit 0。
- 生成文件 `/nix/store/5iaqf0ffyhxi3lfbb0af968n9m1h71vh-home-manager-generation/home-files/.config/hypr/hyprland.lua`：`hl.plugin.load` 恰好 1 行。
- 新插件 `.so`：`strings` 中已无 `Initialized successfully!`；仍保留 `Version mismatch` 错误通知与全部 `plugin:borders-plus-plus:*` 配置项。
- reload 路径：`hyprctl reload` 后 `#hl.get_loaded_plugins()` 仍为 1（修复前即无重复加载），未产生 `Cannot load a plugin twice`。
- `git diff --check` → exit 0。

## 5. 提交与推送

- Commit: `1dfc9cd748523eab832940bbc5eefc484b341fa3`
  `fix(hyprland): 消除 borders-plus-plus 启动成功提示`
- Push: `d6531e7..1dfc9cd  main -> main`（exit 0）

注：用户需重新 `nixos-rebuild switch`（或 `home-manager switch`）后新配置才会生效；未执行，按要求只构建。
