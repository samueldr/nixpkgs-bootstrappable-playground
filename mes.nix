{ callPackage, stdenvNoCC, nyaccSource, mescc-tools }:

# FIXME: The output relies on an impure `/bin/sh` existing.
# We should upstream a fix that completely removes the need
# for shell scripts for the few wrappers.

let
  # We're wrapping with `callPackage` so we can `.override` inside of
  # this derivation.
  mes-boot = callPackage (
    { stdenv
    , fetchFromSavannah
    , makeWrapper
    , nyaccSource
    , mescc-tools
    # "Is this build using mescc", rather than "is this the first build".
    , isBootstraping ? false
    }:

    stdenv.mkDerivation rec {
      pname = "mes${if isBootstraping then "" else "-boot"}";
      version = "0.21";

      src = fetchFromSavannah {
        repo = "mes";
        rev = "v${version}";
        sha256 = "1cfs7q7lx1jap6dwc5vamqk43q2bs1q97i1z6vwvbr2azg32wfkx";
      };

      enableParallelBuilding = true;
      patches = [
        ./0001-mescc-Don-t-depend-on-coreutils.patch
      ];

      NYACC = nyaccSource;

      nativeBuildInputs = [
        makeWrapper
        mescc-tools
      ];

      PS4=" $ ";
      V = "1";

      postPatch = ''
        (
        set -x
        # Copy NyaCC as it's a runtime dependency for mescc.
        cp -r $NYACC/module/nyacc ./module/
        chmod -R +w module/nyacc
        )
      '';

      configurePhase = ''
        sh -x ./configure.sh --prefix=$out
      '';

      buildPhase = ''
        sh -x ./${if isBootstraping then "bootstrap.sh" else "build.sh"}
      '';

      doCheck = true;
      checkPhase = ''
        sh -x ./check.sh
      '';

      installPhase = ''
        sh -x ./install.sh

        (set -x
        wrapProgram $out/bin/mescc \
          --set C_INCLUDE_PATH "$out/include" \
          --set LIBRARY_PATH "$out/lib" \
          --set MES_PREFIX "$out" \
          --set PATH "${mescc-tools}/bin"
        )
      '';

      fixupPhase = ''
        echo "(Skipping fixupPhase)"

        # Using POSIX /bin/sh to escape from nix dependencies.
        # Eww... it should probably be handled some other way.

        # Handles /bin/sh
        for f in diff.scm mesar .mescc-wrapped; do
          sed -i"" '1c#!/bin/sh' "$out/bin/$f"
        done

        # Handles /bin/sh -e from wrapProgram
        for f in mescc; do
          sed -i"" '1c#!/bin/sh -e' "$out/bin/$f"
        done

        echo "Final checks:"

        (
        set -x
        $out/bin/mesar --help
        $out/bin/mescc --help
        )
      '';

      hardeningDisable = [ "all" ];
    }
  ) {
    inherit mescc-tools nyaccSource;
  };
in
  # This specialization uses the `mes-boot`
  (mes-boot.override{
    stdenv = stdenvNoCC;
    isBootstraping = true;
  }).overrideAttrs({passthru ? {}, ...}: {
    AR = "${mes-boot}/bin/mesar";
    CC = "${mes-boot}/bin/mescc";
    MES_PREFIX = "${mes-boot}/share/mes";

    passthru = passthru // {
      inherit mes-boot;
    };
  })
