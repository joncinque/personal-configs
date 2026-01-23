# git.nix: setup git and config
{ pkgs, ...}:
{
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Jon C";
        email = "me@jonc.dev";
        # TODO get the key
        signingkey = "/home/jon/.ssh/github_id_rsa.pub";
      };
      credential.helper = "cache --timeout=3600";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        renames = true;
        submodule = "log";
      };
      alias = {
        g = "grep";
        b = "branch";
        s = "switch";
        d = "diff";
        fp = "fetch --prune";
        st = "status";
        pl = "pull --rebase";
        plum = "pull --rebase upstream main";
        plums = "pull --rebase upstream master";
      };
      column.ui = "auto";
      fetch.prune = true;
      push.default = "simple";
      pull.rebase = true;
      core = {
        autocrlf = "input";
        commentChar = ";";
        #excludesfile = ~/.gitignore_global
      };
      merge.conflictstyle = "zdiff3";
      init.defaultBranch = "main";
      commit.verbose = true;
      commit.gpgsign = true;
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      status.submoduleSummary = true;
      submodule.recurse = true;
      gpg.format = "ssh";
      tag = {
        sort = "version:refname";
        gpgSign = true;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    git-cliff
  ];
}
