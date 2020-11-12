{ stdenv, python3Packages, fetchFromGitHub, makeWrapper, substituteAll }:

stdenv.mkDerivation rec {
  pname = "bpytop";
  version = "1.0.47";

  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = pname;
    rev = "v${version}";
    sha256 = "1zsxqnisb9zyji6xwl4b7r722mr0g4hs3a74xsfghd5kafvgzj24";
  };

  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = with python3Packages; [ python psutil ];

  dontBuild = true;

  postPatch = ''
    sed -i -e "s#/usr/\[local/\]#$out/#g" \
           -e "s#/usr/{td}#$out/#g" \
           -e "s#THEME_DIR: str = \"\"#THEME_DIR: str = \"$out/share/bpytop/themes\"#" \
      ./bpytop.py
  '';

  installPhase = ''
    mkdir -p $out/{bin,libexec,share/bpytop}/
    cp -r ./themes $out/share/bpytop/
    cp ./bpytop.py $out/libexec/

    makeWrapper ${python3Packages.python.interpreter} $out/bin/bpytop \
      --add-flags "$out/libexec/bpytop.py" \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  meta = with stdenv.lib; {
    description = "A resource monitor; python port of bashtop";
    homepage = src.meta.homepage;
    license = licenses.apsl20;
    maintainers = with maintainers; [ aw ];
    platforms = with platforms; linux ++ freebsd ++ darwin;

    # https://github.com/NixOS/nixpkgs/pull/94625#issuecomment-668509399
    broken = stdenv.isDarwin;
  };
}
