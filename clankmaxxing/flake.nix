{
  description = "Clankmaxxing dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          strictDeps = true;

          # host/target agnostic programs
          depsBuildBuild = with pkgs; [
          ];

          # compilers & linkers & dependency finding programs
          nativeBuildInputs = with pkgs; [
            pkg-config
            gnumake
            pnpm
            nodejs
            rustup
            devcontainer
            lmstudio
            nvtopPackages.nvidia
          ];

          # libraries
          buildInputs = with pkgs; [
            openssl
          ];

          RUST_BACKTRACE = 1;
        };
      }
    );
}
