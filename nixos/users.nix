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
        "docker" "wheel" "networkmanager" "systemd-journal"
      ];
      shell = "/run/current-system/sw/bin/fish";
      initialHashedPassword = "$6$bduI6eg7lcAi7lzN$kSc2GbzsXbfN7JCSfNteGddhX/ZE1J.CXQZdEkQ5uO8BoCyDOrCGfAidByQlc2cFgJ2o4yKjPnBxXKMNtqN/F1";
    };

    # Devcontainer group
    groups = {
      g100999 = {
        gid = 100999;
        members = [ "jon" ];
      };
    };
  };

  security.pam.loginLimits = [
    {
      domain = "jon";
      type = "-";
      item = "nofile";
      value = "1000000";
    }
    {
      domain = "jon";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];
}
