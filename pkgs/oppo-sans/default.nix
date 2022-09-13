{ stdenvNoCC
, lib
, fetchurl
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  pname = "oppo-sans";
  version = "0.1";
  src = fetchurl ({
    url = "https://static01.coloros.com/www/public/img/topic7/font-opposans.zip?242";
    sha256 = "MPrqqXwYX9Ij4h7jiOktTyxx52p17oVKt+ZowcH6d1M=";
  });

  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,truetype}/
    cp */*.otf $out/share/fonts/opentype/
    cp */*.ttc $out/share/fonts/truetype/
  '';
}
