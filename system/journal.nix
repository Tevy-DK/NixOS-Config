# 借鉴 koru：限制 journald 的磁盘占用（VM 长期跑日志会一直涨）
{ ... }:
{
  services.journald.settings.Journal = {
    SystemMaxUse = "500M";
    SystemKeepFree = "1G";
    MaxRetentionSec = "2week";
  };
}
