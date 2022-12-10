{ config
, pkgs
, lib
, ...
}:

{
  environment.systemPackages = [ pkgs.btrbk ];

  systemd.services.btrbk = {
    description = "btrbk backup";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk run";
    };
  };

  systemd.timers.btrbk = {
    description = "btrbk backup periodic";
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnUnitInactiveSec = "15min";
      OnBootSec = "15min";
    };
  };

  environment.etc."btrbk/btrbk.conf".text = ''
    timestamp_format        long
    snapshot_preserve_min   18h
    snapshot_preserve       48h 
    volume /persist
      snapshot_dir .snapshots
      subvolume .
      snapshot_create onchange
  '';

}