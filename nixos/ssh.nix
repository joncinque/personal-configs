# ssh.nix: configure (I think installation happens elsewhere)
{ ... }:
{
  programs.ssh = {
    extraConfig = ''
ServerAliveInterval 10
ServerAliveCountMax 1
Host github.com
    Hostname github.com
    User git
    IdentityFile ~/.ssh/github_id_rsa
Host gitlab.com
    Hostname gitlab.com
    User git
    IdentityFile ~/.ssh/github_id_rsa
    '';
  };
  # Put the key file into ~/.ssh
}

