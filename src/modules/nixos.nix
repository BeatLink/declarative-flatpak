{ config, lib, pkgs, ... }:

let
  inherit (pkgs) callPackage;
  inherit (lib) mkIf;
  
  cfg = config.services.flatpak;
in

{
  imports = [
    (import ../options.nix { inherit cfg; })
  ];
  
  config.systemd.services."manage-system-flatpaks" = mkIf cfg.enableModule {
    description = "Manage system-wide flatpaks";
    serviceConfig.Type = "exec";
    wants = mkIf cfg.runOnActivation [
      "network-online.target"
    ];
    after = mkIf cfg.runOnActivation [
      "network-online.target"
      (mkIf cfg.waitForInternet "nss-lookup.target")
    ];
    wantedBy = mkIf cfg.runOnActivation [
      "multi-user.target"
    ];
    script = "${callPackage ../script.nix {
      inherit cfg config;
      is-system-install = true;
    }}";
    startAt = mkIf (cfg.onCalendar != null) cfg.onCalendar;
  };
  config.systemd.timers."manage-system-flatpaks" = mkIf (cfg.enableModule && cfg.onCalendar != null) {
    unitConfig = {
      Wants = [
        "network-online.target"
      ];
      After = [
        "network-online.target"
      ] ++ (if cfg.waitForInternet then [ "nss-lookup.target" ] else []);
    };
    timerConfig = {
      OnCalendar = cfg.onCalendar;
      Persistent = true;
    };
  };
}