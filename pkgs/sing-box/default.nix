{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.1-2";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    sha256 = "sha256-FbW2h/muCk/vAItYHYRA/DFFPQvmTqNq74XUZQkUXaA=";
  };

  vendorSha256 = "sha256-kJE+1bekIpv36cG0/Gi25kjnJmTjTp6lt344kFCUSXI=";

  proxyVendor = true;

  # Do not build testing suit
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sagernet/sing-box/constant.Commit=${version}"
  ];
  
  CGO_ENABLED = 1;

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

  doCheck = false;

  meta = with lib; {
    description = "sing-box";
    homepage = "https://github.com/SagerNet/sing-box";
    license = licenses.gpl3Only;
#    maintainers = with maintainers; [ oluceps ];
  };
}
