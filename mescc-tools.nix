{ stdenv, fetchFromSavannah, which }:

stdenv.mkDerivation {
  pname = "mescc-tools";
  version = "1.0.1+2020-11-08";

  src = fetchFromSavannah {
    repo = "mescc-tools";
    rev = "530d08f075783ce7c8d9050f3d36a997cf4389e3";
    sha256 = "0r1lyxn4885hybz32a7bjqkjzagbb97kp2ywsxy2jkqv1080p3ah";
  };

  nativeBuildInputs = [
    which
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  doCheck = true;
  checkPhase = ''
      make test
  '';
}
