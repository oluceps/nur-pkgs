{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.1-1";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "8afb8ca7eb8aa52e7a3b44253be0f3df9474fa64";
    sha256 = "sha256-CNy+C5E5iAZHZ7PsS0Hj43irCuCvy/bes3kovvH81/o=";
  };

  vendorSha256 = "sha256-fUHfvqzbu2P7N413dDuV41myhReNSYvgF+Cc6SgG6y4=";

  # Do not build testing suit
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sagernet/sing-box/constant.Commit=${version}"
  ];
  
  tags = [
    "with_quic"
    "with_grpc"
    "with_wireguard"
    "with_utls"
    "with_ech"
    "with_gvisor"
    "with_clash_api"
    "with_lwip"
  ];

  CGO_ENABLED = 1;
  doCheck = false;

  meta = with lib; {
    description = "sing-box";
    homepage = "https://github.com/SagerNet/sing-box";
    license = licenses.gpl3Only;
#    maintainers = with maintainers; [ oluceps ];
  };
}
