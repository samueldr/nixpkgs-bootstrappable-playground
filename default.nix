let
  nixpkgs_src = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-20.09.tar.gz";
    sha256 = "19khdgb8dp28rx4wyb2m2dxdcq83dhidj6046rynb91dfdm6893n";
  };

  nixpkgs = import nixpkgs_src {
    # Not supported for the time being.
    # system = "x86_64-linux";

    # With mes 0.21, only i686-linux is known to work.
    system = "i686-linux";
  };

  inherit (nixpkgs)
    callPackage
    fetchFromSavannah
    runCommandNoCC
  ;
in

rec {

  nyaccSource = fetchFromSavannah {
    repo = "nyacc";
    rev = "rel-0.99";
    sha256 = "1mg8vj1r8xfii0jin1yqkhzniz950dagh1chqvzkaiiyxdqqs007";
  };

  mescc-tools = nixpkgs.pkgsStatic.callPackage ./mescc-tools.nix {};

  mes = callPackage ./mes.nix {
    inherit
      nyaccSource
      mescc-tools
    ;
  };

  tests = {
    hello-mes = runCommandNoCC "hello-mes" {
      buildInputs = [
        mes
      ];
    } ''
      (PS4=" $ " set -x
      mescc -o hello ${./hello-mes.c}
      ./hello
      mv hello $out
      )
    '';
    hello-mes-printf = runCommandNoCC "hello-mes-printf" {
      buildInputs = [
        mes
      ];
    } ''
      (PS4=" $ " set -x
      mescc -o hello ${./hello-printf.c} -l c+tcc
      ./hello
      mv hello $out
      )
    '';
    hello-tcc-printf = runCommandNoCC "hello-tcc-printf" {
      buildInputs = [
        tinycc-boot
      ];
    } ''
      (PS4=" $ " set -x
      tcc -o hello ${./hello-printf.c}
      ./hello
      mv hello $out
      )
    '';
  };

  tinycc-boot = callPackage ./tinycc-boot.nix {
    inherit
      mescc-tools
      mes
    ;
  };
}
