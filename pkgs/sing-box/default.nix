{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "7279855b08a11bb4ebb3d7be91434ec643bf7c35";
    sha256 = "sha256-lbPsdvlUmLQjId9wpD2srW+Z7x37wRJ6pCO5jskEXhs=";
  };

  vendorSha256 = "sha256-x9G2u9LqMvVCPnKCid3cer6a8Ncydo+z02cYTZobCMs=";

  # Do not build testing suit
  excludedPackages = [ "./test" ];

  CGO_ENABLED = 1;
  proxyVendor = true;
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
