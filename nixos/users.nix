# users.nix: setup system users

{ ... }:
{
  users = {
    mutableUsers = true;
    users.jon = {
      isNormalUser = true;
      createHome = true;
      uid = 1000;
      group = "users";
      extraGroups = [
        "docker" "wheel" "netdev" "networkmanager" "systemd-journal"
      ];
      shell = "/run/current-system/sw/bin/fish";
      initialHashedPassword = "$6$bduI6eg7lcAi7lzN$kSc2GbzsXbfN7JCSfNteGddhX/ZE1J.CXQZdEkQ5uO8BoCyDOrCGfAidByQlc2cFgJ2o4yKjPnBxXKMNtqN/F1";
    };
  };
}
