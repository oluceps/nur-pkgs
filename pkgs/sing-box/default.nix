{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "a37cab48d23cd14d95c65c1fe69e7d9f820afedb";
    sha256 = "sha256-ajPvM0g6tIKbvkm+wiqxUiLTxiEvRASsHWiLggcNfz0=";
  };

  vendorSha256 = "sha256-x9G2u9LqMvVCPnKCid3cer6a8Ncydo+z02cYTZobCMs=";

  # Do not build testing suit
  excludedPackages = [ "./test" ];

  CGO_ENABLED = 1;
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sagernet/sing-box/constant.Commit=${version}"
  ];

  meta = with lib; {
    description = "sing-box";
    homepage = "https://github.com/SagerNet/sing-box";
    license = licenses.gpl3Only;
#    maintainers = with maintainers; [ oluceps ];
  };
}
