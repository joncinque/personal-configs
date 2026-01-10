# sys.nix

{ pkgs, ... }:

{
  # Enable cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      #"*/5 * * * * jon cd /home/jon/src/epaper/e-Paper/RaspberryPi_JetsonNano/python && ./venv/bin/python3 examples/hi.py > /dev/null 2>&1"
      "7 11 * * * jon /home/jon/src/sys/daily.sh 2>&1"
      "30 4 * * 0     root   /run/current-system/sw/bin/nix-channel --update && /run/current-system/sw/bin/nixos-rebuild switch && /run/current-system/sw/bin/shutdown -r now"
    ];
  };
}

