{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, alsa-lib
, ffmpeg
, libvdpau
, soxr
, xvidcore
, libogg
, bzip2
, lzma
, lame
, libtheora
}:

rustPlatform.buildRustPackage rec {
  pname = "RustPlayer";
  version = "2022-12-29";

  src = fetchFromGitHub {
    rev = "a369bc19ab4a8c568c73be25c5e6117e1ee5d848";
    owner = "Kingtous";
    repo = pname;
    hash = "sha256-x82EdA7ezCzux1C85IcI2ZQ3M95sH6/k97Rv6lqc5eo=";
  };

  cargoHash = "sha256-1oxiojSgwTApdV1nK4c7UDvPiKqt6cxVPHlnS5isJZA=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    openssl
    ffmpeg
    libvdpau
    libogg
    soxr
    xvidcore
    bzip2
    lzma
    lame
    libtheora
  ];

  # network required
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/Kingtous/RustPlayer";
    description = ''
      An local audio player & m3u8 radio player using
      Rust and completely terminal guimusical_note
    '';
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [ oluceps ];
  };
}
