{
  pkgs ? null,
  hexOrganization ? null, # organization account name on hex.pm
  hexApiKey ? null,       # plain text account API key on hex.pm
  robotSshKey ? null      # base64-encoded private id_rsa (for private git)
}:
let overlays = [
      (import ./overlay.nix {inherit hexOrganization hexApiKey robotSshKey;})
    ];
    localPkgs = import ./nixpkgs.nix;
    nixpkgs = if pkgs == null then import localPkgs {inherit overlays;} else pkgs;
in
with nixpkgs;

let callPackage = lib.callPackageWith haskellPackages;
    pkg = callPackage ./pkg.nix {inherit stdenv;};
    systemDeps = [ protobuf makeWrapper cacert ];
    testDeps = [ postgresql ];
in
  haskell.lib.overrideCabal pkg (drv: {
    setupHaskellDepends =
      if drv ? "setupHaskellDepends"
      then drv.setupHaskellDepends ++ systemDeps
      else systemDeps;
    testSystemDepends =
      if drv ? "testSystemDepends"
      then drv.testSystemDepends ++ testDeps
      else testDeps;
    isExecutable = true;
    enableSharedExecutables = false;
    enableLibraryProfiling = false;
    isLibrary = false;
    doHaddock = false;
    preCheck = ''
      source ./nix/export-test-envs.sh;
      sh ./nix/reset-test-data.sh;
      sh ./nix/spawn-test-deps.sh;
    '';
    postCheck = ''
      sh ./nix/shutdown-test-deps.sh
    '';
    postFixup = ''
      rm -rf $out/lib $out/nix-support $out/share/doc
      cp -R ./static $out/static
      cp -R ./config $out/config
    '';
    postInstall = ''
      wrapProgram "$out/bin/lightning-tip" \
        --set SYSTEM_CERTIFICATE_PATH "${cacert}/etc/ssl/certs"
    '';
  })
