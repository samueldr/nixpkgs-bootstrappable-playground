{ runCommandNoCC, fetchFromGitLab, mes, mescc-tools }:
# Here we're using `runCommandNoCC` to somewhat reduce risks of
# contamination from stdenv.
# The product should be entirely independent from the Nixpkgs it was
# built from.
runCommandNoCC "tinycc-boot" rec {
  version = "0.9.27+mes-${mes.version}";
  src = fetchFromGitLab {
    owner = "janneke";
    repo = "tinycc";
    # mes-0.21
    rev = "20b1a1d001760973fadc9656f4210d8e4bd9470d";
    sha256 = "1mk4l9zvwavrvlvz6xwzlhgnwwgg8bmmxfxma651wcrk3k2hhacd";
  };

  nativeBuildInputs = [
    mescc-tools
    mes
  ];
} ''
  export PS4=" $ "

  echo ":: Unpacking"
  (set -x
  cp -prf $src src
  chmod -R +w src
  )

  cd src

  # We need to copy mes into the work tree as the build system wants to
  # mutate the contents.
  echo ":: Splicing in mes"
  (set -x
  cp -prf ${mes} mes
  chmod -R +w mes

  # Checks an expected file is present
  ls -l mes/lib/crt1.c
  )

  echo ":: Configuring"

  export prefix="$out"
  export MES_PREFIX="$PWD/mes"

  (set -x
  sh ./configure \
    --cc=mescc \
    --prefix=$out \
    --elfinterp=$out/lib/mes-loader \
    --crtprefix=. \
    --tccdir=.
  )

  echo ":: Building"

  (set -x
  sh -x bootstrap.sh
  )

  echo ":: Checking"

  (set -x
  set +e
  ./tcc -h
  val=$?
  if test $val -ne 1; then
    echo "error: tcc -h exited with $val, 1 expected."
    exit $val
  fi
  )

  echo ":: Installing"

  (set -x
  sh -x install.sh
  )
''

