# --- cursor ---
# 借鉴 koru：把 Bibata Modern 光标按全局主题重着色 —— 深色填充 + 主题蓝描边。
# 与 config.kdl 的 cursor 块同名（Bibata-Modern-DK），GTK 侧由 home.pointerCursor 注入。
{ pkgs, theme, ... }:

let
  dkCursor = pkgs.stdenvNoCC.mkDerivation {
    pname = "bibata-cursors-dk";
    version = "2.0.7";

    src = pkgs.fetchFromGitHub {
      owner = "ful1e5";
      repo = "Bibata_Cursor";
      rev = "v2.0.7";
      hash = "sha256-kIKidw1vditpuxO1gVuZeUPdWBzkiksO/q2R/+DUdEc=";
    };

    bitmaps = pkgs.fetchzip {
      url = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/bitmaps.zip";
      hash = "sha256-4VjyNWry0NPnt5+s0od/p18gry2O0ZrknYZh+PAPM8Q=";
    };

    nativeBuildInputs = [
      pkgs.clickgen
      pkgs.imagemagick
    ];

    buildPhase = ''
      runHook preBuild

      # 给琥珀色位图重新上色：填充换成 theme.black，白边换成 theme.accent
      mkdir -p $PWD/bitmaps
      cp -r $bitmaps/Bibata-Modern-Amber $PWD/bitmaps/Bibata-Modern-DK
      chmod -R u+w $PWD/bitmaps/Bibata-Modern-DK
      find $PWD/bitmaps/Bibata-Modern-DK -name '*.png' -exec convert {} -fuzz 15% -fill '${theme.black}' -opaque '#FF8300' -type TrueColorMatte PNG32:{} \;
      find $PWD/bitmaps/Bibata-Modern-DK -name '*.png' -exec convert {} -fuzz 12% -fill '${theme.accent}' -opaque '#FFFFFF' -type TrueColorMatte PNG32:{} \;

      ctgen configs/normal/x.build.toml -p x11 \
        -d $PWD/bitmaps/Bibata-Modern-DK \
        -n 'Bibata-Modern-DK' \
        -c 'Bibata Modern recolored to the global theme accent' \
        -o $PWD/themes

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -dm 0755 $out/share/icons
      cp -rf $PWD/themes/Bibata-Modern-DK $out/share/icons/
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Bibata Modern cursor recolored to the global theme colors";
      homepage = "https://github.com/ful1e5/Bibata_Cursor";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
in
{
  # 会话里唯一的光标定义：home-manager 由此派生 GTK 光标（gtk.enable），
  # 并导出 XCURSOR_THEME/-SIZE；niri 通过 config.kdl 的 cursor 块读取同名主题。
  home.pointerCursor = {
    enable = true;
    name = theme.cursor-name;
    package = dkCursor;
    size = theme.cursor-size;
    gtk.enable = true;
  };
}
