{
  pkgs,
  lib,
  stdenv,
  udevCheckHook,
}:

stdenv.mkDerivation rec {
  pname = "keystone-udev-rules";
  version = "1";

  src = ./.;

  nativeBuildInputs = [
    udevCheckHook
  ];

  doInstallCheck = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    cp $src/52-keystone.rules $out/lib/udev/rules.d/
  '';

  meta = {
    description = "Udev rules for Keystone";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    homepage = "https://gist.github.com/MSalopek/aba9fb40a738a48b55179fcee001ac1f";
  };
}
