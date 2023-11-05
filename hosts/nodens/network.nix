{ config
, lib
, ...
}: {
  services.udev.extraRules = ''
    ATTR{address}=="62:16:bf:7c:57:a3", NAME="eth0"
    ATTR{address}=="22:48:a2:5b:0b:f0", NAME="eth1"
  '';

  networking = {
    resolvconf.useLocalResolver = true;
    firewall = {
      checkReversePath = false;
      enable = true;
      trustedInterfaces = [ "virbr0" "wg0" "wg1" ];
      allowedUDPPorts = [ 80 443 8080 5173 23180 4444 51820 ];
      allowedTCPPorts = [ 80 443 8080 9900 2222 5173 8448 ];
    };

    useNetworkd = true;
    useDHCP = false;

    hostName = "nodens";
    enableIPv6 = true;

    nftables.enable = true;
    networkmanager.enable = lib.mkForce false;
    networkmanager.dns = "none";

  };
  systemd.network = {
    enable = true;

    wait-online = {
      enable = true;
      anyInterface = true;
      ignoredInterfaces = [ "wg0" "wg1" ];
    };

    links."10-eth0" = {
      matchConfig.MACAddress = "62:16:bf:7c:57:a3";
      linkConfig.Name = "eth0";
    };
    links."20-eth1" = {
      matchConfig.MACAddress = "22:48:a2:5b:0b:f0";
      linkConfig.Name = "eth1";
    };

    netdevs = {

      wg1 = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg1";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wgy.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "BCbrvvMIoHATydMkZtF8c+CHlCpKUy1NW+aP0GnYfRM=";
              AllowedIPs = [ "10.0.1.2/32" ];
              PersistentKeepalive = 15;
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "i7Li/BDu5g5+Buy6m6Jnr09Ne7xGI/CcNAbyK9KKbQg=";
              AllowedIPs = [ "10.0.1.3/32" ];
              PersistentKeepalive = 15;
            };
          }

          {
            wireguardPeerConfig = {
              PublicKey = "ANd++mjV7kYu/eKOEz17mf65bg8BeJ/ozBmuZxRT3w0=";
              AllowedIPs = [
                "10.0.0.0/24"
                "10.0.1.0/24"
              ];
              Endpoint = "111.229.162.99:51820";
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };


    networks = {
      "10-wg1" = {
        matchConfig.Name = "wg1";
        address = [
          "10.0.1.1/24"
          "10.0.0.5/24"
        ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPForward = true;
        };
      };

      "20-eth0" = {
        matchConfig.Name = "eth0";
        # DHCP = "yes";
        # dhcpV4Config.RouteMetric = 2046;
        # dhcpV6Config.RouteMetric = 2046;
        address = [
          "144.126.208.183/20"
          "10.48.0.5/16"
          "2604:a880:4:1d0::5b:6000/64"
          "fe80::6016:bfff:fe7c:57a3/64"
        ];

        gateway = [ "144.126.208.1" "2604:a880:4:1d0::1" ];

        networkConfig = {
          # Bond = "bond1";
          # PrimarySlave = true;
          DNSSEC = true;
          MulticastDNS = true;
          DNSOverTLS = true;
        };
        # # REALLY IMPORTANT
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
      };

      "30-eth1" = {
        matchConfig.Name = "eth1";
        # DHCP = "yes";
        # dhcpV4Config.RouteMetric = 2046;
        # dhcpV6Config.RouteMetric = 2046;
        address = [
          "10.124.0.2/20"
          "fe80::2048:a2ff:fe5b:bf0/64"
        ];

        networkConfig = {
          DNSSEC = true;
          MulticastDNS = true;
          DNSOverTLS = true;
        };
        # # REALLY IMPORTANT
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
      };
    };
  };
}