let
  nixpkgs = import <nixpkgs> {};

  mes-test = import ./mes-test.nix;
in

  nixpkgs.mkShell {
    name = "mes-test-shell";
    buildInputs = with mes-test; [
      mescc-tools
      mes-boot
    ];
  }
