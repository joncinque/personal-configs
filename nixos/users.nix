# users.nix: setup system users

{ ... }:
{
  users.users.jon = {
    isNormalUser = true;
    createHome = true;
    uid = 1000;
    group = "users";
    extraGroups = [
      "docker" "wheel" "netdev" "networkmanager" "systemd-journal"
    ];
    shell = "/run/current-system/sw/bin/fish";
    hashedPassword = "$y$j9T$MYgokv.cnZu/w4M5ACKqs1$C2V7QzxDFDp3unyOJ6H4BJYe0GfaLpy0a6M5Fk8jLs7";
  };
}
