{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  SDL2,
  libpng,
  libiconv,
  libobjc,
  autoreconfHook
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "qrencode";
  version = "4.1.1";

  outputs = [
    "bin"
    "out"
    "man"
    "dev"
  ];

  src = fetchurl {
    url = "https://github.com/fukuchi/libqrencode/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-U4W8G4wvIPO5HSWL+MzIz2ICOTXfLSZ2tbZwSfMaBJw=";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook ];

  buildInputs = [
    libiconv
    libpng
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libobjc ];

  nativeCheckInputs = [ SDL2 ];

  doCheck = false;

  checkPhase = ''
    runHook preCheck

    pushd tests
    ./test_basic.sh
    popd

    runHook postCheck
  '';

  passthru.tests = finalAttrs.finalPackage.overrideAttrs (_: {
    configureFlags = [ "--with-tests" ];
    doCheck = true;
  });

  meta = with lib; {
    homepage = "https://fukuchi.org/works/qrencode/";
    description = "C library for encoding data in a QR Code symbol";
    longDescription = ''
      Libqrencode is a C library for encoding data in a QR Code symbol,
      a kind of 2D symbology that can be scanned by handy terminals
      such as a mobile phone with CCD.
    '';
    license = licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "qrencode";
  };
})
