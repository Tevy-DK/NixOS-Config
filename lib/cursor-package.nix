# 全局光标包：Bibata Modern 按深浅色重着色成两套 ——
#   dark  = 黑体（#000000）+ 白边（#FFFFFF）
#   light = 白体（#FFFFFF）+ 黑边（#000000）
# 两套主题打包在同一 derivation 里，安装后同时可用，由 Noctalia 的
# started / theme_mode_changed hooks 触发 cursor-theme-sync 切换。
#
# 系统层（noctalia-greeter 登录页，system/greeter.nix）与用户层
# （home.pointerCursor，home/cursor-theme.nix）共用这一份 derivation：
# 同一个 pkgs + theme 求出同一个 store path，登录页和桌面会话里的光标包一致。
{ pkgs, theme }:

let
  inherit (theme) cursor-name-dark cursor-name-light;
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "bibata-cursors-mono";
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

    # 两套都从 Amber 位图改色：Amber 的主体是 #FF8300，描边是 #FFFFFF。
    mkdir -p $PWD/bitmaps
    cp -r $bitmaps/Bibata-Modern-Amber $PWD/bitmaps/${cursor-name-dark}
    cp -r $bitmaps/Bibata-Modern-Amber $PWD/bitmaps/${cursor-name-light}
    chmod -R u+w $PWD/bitmaps/${cursor-name-dark} $PWD/bitmaps/${cursor-name-light}

    # dark：只把主体橙色换成黑色，原有白描边保留。
    find $PWD/bitmaps/${cursor-name-dark} -name '*.png' \
      -exec convert {} -fuzz 15% -fill '#000000' -opaque '#FF8300' -type TrueColorMatte PNG32:{} \;

    # light：先把白描边压成黑色，再把主体染成白色。顺序不能反 ——
    # 先染主体会把新生成的白色主体在下一步一并压黑。
    find $PWD/bitmaps/${cursor-name-light} -name '*.png' \
      -exec convert {} -fuzz 12% -fill '#000000' -opaque '#FFFFFF' -type TrueColorMatte PNG32:{} \;
    find $PWD/bitmaps/${cursor-name-light} -name '*.png' \
      -exec convert {} -fuzz 15% -fill '#FFFFFF' -opaque '#FF8300' -type TrueColorMatte PNG32:{} \;

    ctgen configs/normal/x.build.toml -p x11 \
      -d $PWD/bitmaps/${cursor-name-dark} \
      -n '${cursor-name-dark}' \
      -c 'Bibata Modern dark: black body, white outline' \
      -o $PWD/themes

    ctgen configs/normal/x.build.toml -p x11 \
      -d $PWD/bitmaps/${cursor-name-light} \
      -n '${cursor-name-light}' \
      -c 'Bibata Modern light: white body, black outline' \
      -o $PWD/themes

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -dm 0755 $out/share/icons
    cp -rf $PWD/themes/${cursor-name-dark} $out/share/icons/
    cp -rf $PWD/themes/${cursor-name-light} $out/share/icons/
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Bibata Modern recolored in black/white for dark and light schemes";
    homepage = "https://github.com/ful1e5/Bibata_Cursor";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
