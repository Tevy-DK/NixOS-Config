# --- qwen3-embed ---
# 本地嵌入服务：Qwen3-Embedding-0.6B 的 Q8_0 GGUF（639 MiB）+ llama.cpp
# 的 llama-server，跑成 systemd 用户服务，监听 127.0.0.1:8010（OpenAI
# 兼容的 /v1/embeddings）。omp 等客户端把 endpoint 指向这里。
#
# 模型由固定输出派生（fetchurl）下载：走 ModelScope 镜像（上游 HF 慢），
# 哈希锁死，store 里只存一份；首次构建拉 639 MiB，之后直接复用。
# 本模块自己安装 pkgs.llama-cpp（提供 llama-server）并声明该用户服务，
# 服务与包同属一处，不依赖 home/pkgs.nix 的包清单。
{ pkgs, ... }:
let
  model = pkgs.fetchurl {
    name = "Qwen3-Embedding-0.6B-Q8_0.gguf";
    url = "https://modelscope.cn/models/Qwen/Qwen3-Embedding-0.6B-GGUF/resolve/master/Qwen3-Embedding-0.6B-Q8_0.gguf";
    hash = "sha256-BlB8e0JohGnE5ymLCh4W3v8GyvKRzwpbJ4wwgknD5Dk=";
  };
in
{
  # llama-server 由本模块安装，服务与包同属一处，删模块即全清。
  home.packages = [ pkgs.llama-cpp ];

  # systemd.user.enable 在 Linux 上默认 true（HM 选项默认值），无需重复声明。
  systemd.user.services.qwen3-embed = {
    Unit = {
      Description = "Qwen3-Embedding-0.6B Q8_0 embedding server (llama.cpp)";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.llama-cpp}/bin/llama-server --model ${model} --alias Qwen3-Embedding-0.6B-Q8_0 --host 127.0.0.1 --port 8010 --embedding --pooling last --ctx-size 32768 --batch-size 2048 --ubatch-size 2048 --parallel 1 --threads 16 --flash-attn on";
      Restart = "on-failure";
      RestartSec = 3;
      Nice = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # 这两条路径由上面的 systemd.user.services 自动生成；这里只把 force 合并进去。
  # 旧的手写单元（普通文件）与它的 .wants 链接已在 ~/.config/systemd/user 里，
  # HM 的 link target 检查拒绝覆盖指向别处的链接，force 让激活直接替换成
  # store 链接（home.backupFileExtension 管不了 .wants 链接，故不用它）。
  xdg.configFile."systemd/user/qwen3-embed.service".force = true;
  xdg.configFile."systemd/user/default.target.wants/qwen3-embed.service".force = true;
}
