# ssh.nix: configure (I think installation happens elsewhere)
{ ... }:
{
  programs.ssh = {
    extraConfig = ''
ServerAliveInterval 30
ServerAliveCountMax 3
Host github.com
    Hostname github.com
    User git
    IdentityFile ~/.ssh/github_id_rsa
Host gitlab.com
    Hostname gitlab.com
    User git
    IdentityFile ~/.ssh/github_id_rsa
Host codeberg.org
    Hostname codeberg.org
    User git
    IdentityFile ~/.ssh/codeberg_id_ed25519
    '';
  };
  # Put the key file into ~/.ssh
}

