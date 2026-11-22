# omp = oh-my-pi：pi 编码代理的配置/技能套件（上游包名就是 omp）。
# 包来自自建 Tevy-DK-attic flake（只取上游 Release 二进制），
# 版本与哈希由该 flake 维护。
{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.omp
  ];

  # omp 的本地 embedding 是 fastembed；mnemopi settings 里的
  # embeddingVariant=multilingual 对应 intfloat/multilingual-e5-large（1024d）。
  # binary-vectors 只按环境变量取维度，不设会退回 384 并截断向量。
  home.sessionVariables = {
    MNEMOPI_EMBEDDING_DIM = "1024";
    HF_ENDPOINT = "https://hf-mirror.com";
  };
  systemd.user.sessionVariables = {
    MNEMOPI_EMBEDDING_DIM = "1024";
    HF_ENDPOINT = "https://hf-mirror.com";
  };
}
