{ lib
, stdenv
, unzip
, fetchurl
}:

let
  maple-font = { pname, version, sha256, desc }: stdenv.mkDerivation
    rec{

      inherit pname version desc;
      src = fetchurl {
        url = "https://github.com/subframe7536/Maple-font/releases/download/v${version}/${pname}.zip";
        inherit sha256;
      };

      # Work around the "unpacker appears to have produced no directories"
      # case that happens when the archive doesn't have a subdirectory.
      setSourceRoot = "sourceRoot=`pwd`";
      nativeBuildInputs = [ unzip ];
      installPhase = ''
        find . -name '*.ttf'    -exec install -Dt $out/share/fonts/truetype {} \;
      '';

      meta = with lib; {
        homepage = "https://github.com/subframe7536/Maple-font";
        description = ''
          Open source ${desc} font with round corner and ligatures for IDE and command line
        '';
        license = licenses.ofl;
        platforms = platforms.all;
        maintainers = with maintainers; [ oluceps ];
      };

    };
in
{
  Mono-v5 = maple-font {
    pname = "MapleMono";
    version = "6.0";
    sha256 = "";
    desc = "monospace";
  };
  Mono-NF-v5 = maple-font {
    pname = "MapleMono-NF";
    version = "6.0";
    sha256 = "";
    desc = "Nerd Font";
  };

}


