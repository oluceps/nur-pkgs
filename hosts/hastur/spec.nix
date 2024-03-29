{ pkgs, data, config, user, lib, inputs, ... }: {
  # This headless machine uses to perform heavy task.
  # Running database and web services.

  system.stateVersion = "22.11"; # Did you read the comment?

  zramSwap = {
    enable = false;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  programs = {
    anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
    niri.enable = true;
    sway.enable = true;
  };
  systemd = {
    services = {
      atuin.serviceConfig.Environment = [ "RUST_LOG=debug" ];
      restic-backups-persist.serviceConfig.Environment = [ "GOGC=20" ];
      btrfs-scrub-persist.serviceConfig.ExecStopPost =
        lib.genNtfyMsgScriptPath "tags red_circle prio high" "error" "btrfs scrub failed on hastur";
    };

    # systemd.services.tester = {
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "exit 3";
    #     ExecStopPost = lib.genNtfyMsgScriptPath "tags warning prio high" "info" "test";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };

    # hardware = {
    #   nvidia = {
    #     package = config.boot.kernelPackages.nvidiaPackages.latest;
    #     modesetting.enable = true;
    #     powerManagement.enable = false;
    #     open = true;
    #   };

    #   opengl = {
    #     enable = true;
    #     # extraPackages = with pkgs; [
    #     #   rocm-opencl-icd
    #     #   rocm-opencl-runtime
    #     # ];
    #     driSupport = true;
    #     driSupport32Bit = true;
    #   };
    # };


    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 10s.
      # If the hardware watchdog does not get a signal for 20s,
      # it will forcefully reboot the system.
      runtimeTime = "20s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';

  };

  # photoprism minio
  networking.firewall.allowedTCPPorts =
    [ 9000 9001 6622 ] ++ [ config.services.photoprism.port ];

  xdg.portal.wlr.enable = true;
  xdg.portal.enable = true;

  programs.dconf.enable = true;

  services = (
    let importService = n: import ../../services/${n}.nix { inherit pkgs config inputs lib; }; in lib.genAttrs [
      "openssh"
      # "mosproxy"
      "fail2ban"
      "dae"
      "scrutiny"
      "ddns-go"
      "atticd"
      # "prometheus"
    ]
      (n: importService n)
  ) // {
    prometheus.exporters.node = {
      enable = true;
      listenAddress = "0.0.0.0";
      enabledCollectors = [ "systemd" ];
      disabledCollectors = [ "arp" ];
    };
    fwupd.enable = true;

    prom-ntfy-bridge.enable = true;
    # xserver.videoDrivers = [ "nvidia" ];

    # xserver.enable = true;
    # xserver.displayManager.gdm.enable = true;
    # xserver.desktopManager.gnome.enable = true;

    copilot-gpt4.enable = true;
    # nextchat.enable = true;

    snapy.instances = [
      {
        name = "persist";
        source = "/persist";
        keep = "2day";
        timerConfig.onCalendar = "*:0/10";
      }
      {
        name = "var";
        source = "/var";
        keep = "7day";
        timerConfig.onCalendar = "daily";
      }
    ];

    tailscale = { enable = true; openFirewall = true; };

    sing-box.enable = false;
    beesd.filesystems = {
      os = {
        spec = "LABEL=nixos";
        hashTableSizeMB = 1024; # 256 *2 *2
        verbosity = "crit";
        extraOptions = [
          "-c"
          "6"
        ];
      };
    };
    restic.backups.solid = {
      passwordFile = config.age.secrets.wg.path;
      repositoryFile = config.age.secrets.restic-repo.path;
      environmentFile = config.age.secrets.restic-envs.path;
      paths = [ "/persist" "/var" ];
      extraBackupArgs = [
        "--one-file-system"
        "--exclude-caches"
        "--no-scan"
        "--retry-lock 2h"
      ];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "4h";
        FixedRandomDelay = true;
        Persistent = true;
      };
    };
    # cloudflared = {
    #   enable = true;
    #   environmentFile = config.age.secrets.cloudflare-garden-00.path;
    # };
    compose-up.instances = [
      {
        name = "misskey";
        workingDirectory = "/home/${user}/Src/misskey";
      }
      {
        name = "nextchat";
        workingDirectory = "/home/${user}/Src/ChatGPT-Next-Web";
        extraArgs = "chatgpt-next-web";
        environmentFile = config.age.secrets.nextchat.path;
      }
    ];

    hysteria.instances = [{
      name = "nodens";
      configFile = config.age.secrets.hyst-us-cli.path;
    }
      {
        name = "colour";
        configFile = config.age.secrets.hyst-az-cli.path;
      }];

    shadowsocks.instances = [
      {
        name = "rha";
        configFile = config.age.secrets.ss-az.path;
        serve = {
          enable = true;
          port = 6059;
        };
      }
    ];

    gvfs.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command =
            "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.writeShellScript "sway" ''
          export $(/run/current-system/systemd/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
          exec sway
        ''}";
          user = "greeter";
        };

      };
    };

    keycloak = {
      enable = false;
      settings = {
        http-host = "10.0.1.2";
        http-port = 8125;
        proxy = "edge";
        hostname-strict-backchannel = true;
        hostname = "id.nyaw.xyz";
        cache = "local";
      };
      database.passwordFile = toString (pkgs.writeText "password" "keycloak");
    };

    surrealdb = {
      enable = true;
      port = 8713;
    };

    postgresqlBackup = {
      enable = true;
      location = "/var/lib/backup/postgresql";
      compression = "zstd";
      startAt = "weekly";
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      enableTCPIP = true;
      port = 5432;
      settings = {
        max_connections = 100;
        shared_buffers = "2GB";
        effective_cache_size = "6GB";
        maintenance_work_mem = "512MB";
        checkpoint_completion_target = 0.9;
        wal_buffers = "16MB";
        default_statistics_target = 100;
        random_page_cost = 1.1;
        effective_io_concurrency = 200;
        work_mem = "5242kB";
        min_wal_size = "1GB";
        max_wal_size = "4GB";
        max_worker_processes = 4;
        max_parallel_workers_per_gather = 2;
        max_parallel_workers = 4;
        max_parallel_maintenance_workers = 2;
      };
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
        local misskey misskey peer map=misskey

        #type database DBuser origin-address auth-method
        # ipv4
        host  all      all     127.0.0.1/32   trust
        host  all      all     10.0.1.1/24   trust
        host  all      all     10.0.0.1/24   trust
        # ipv6
        host all       all     ::1/128        trust
      '';

      ensureDatabases = [ "misskey" ];
      ensureUsers = [
        {
          name = "misskey";
          ensureDBOwnership = true;
        }
      ];
      identMap = ''
        misskey misskey misskey
      '';
    };



    atuin = {
      enable = true;
      host = "0.0.0.0";
      port = 8888;
      openFirewall = true;
      openRegistration = false;
      maxHistoryLength = 65536;
      database.uri = "postgresql://atuin@127.0.0.1:5432/atuin";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    photoprism = {
      enable = true;
      originalsPath = "/var/lib/private/photoprism/originals";
      address = "[::]";
      passwordFile = config.age.secrets.prism.path;
      settings = {
        PHOTOPRISM_ADMIN_USER = "${user}";
        PHOTOPRISM_DEFAULT_LOCALE = "en";
        PHOTOPRISM_DATABASE_NAME = "photoprism";
        PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
        PHOTOPRISM_DATABASE_USER = "photoprism";
        PHOTOPRISM_DATABASE_DRIVER = "mysql";
      };
      port = 20800;
    };


    minio = {
      enable = true;
      region = "ap-east-1";
      rootCredentialsFile = config.age.secrets.minio.path;
    };


    mysql = {
      enable = true;
      package = pkgs.mariadb_1011;
      dataDir = "/var/lib/mysql";
      ensureDatabases = [ "photoprism" ];
      ensureUsers = [
        {
          name = "riro";
          ensurePermissions = {
            "*.*" = "ALL PRIVILEGES";
          };
        }
        {
          name = "photoprism";
          ensurePermissions = {
            "photoprism.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };
    xmrig = {
      enable = false;
      settings = {
        autosave = true;
        opencl = false;
        cuda = false;
        cpu = {
          enable = true;
          max-threads-hint = 90;
        };
        pools = [
          {
            url = "pool.supportxmr.com:443";
            user = data.xmrAddr;
            keepalive = true;
            tls = true;
            pass = "rha";
          }
        ];
      };

    };
  };
}
