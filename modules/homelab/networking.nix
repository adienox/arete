{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.dns;
  dns = cfg.caddy.dns;
  caddyHosts = lib.filterAttrs (
    _: h: h.caddy && (h.upstream != null || h.extraConfig != "")
  ) cfg.hosts;
in
{
  options.homelab.dns = {
    zone = lib.mkOption {
      type = lib.types.str;
      default = "example.com";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "Address records point at";
    };

    hosts = lib.mkOption {
      default = { };
      description = ''
        Subdomains to create A records for, optionally proxied by Caddy.
        A bare port number is shorthand for an upstream on 127.0.0.1.
      '';
      example = lib.literalExpression ''
        {
          redlib = 9090;
          home = {
            upstream = "127.0.0.1:8123";
            extraConfig = "encode gzip";
          };
          printer = { };
        }
      '';
      type = lib.types.attrsOf (
        lib.types.coercedTo lib.types.port (port: { upstream = "127.0.0.1:${toString port}"; }) (
          lib.types.submodule {
            options = {
              upstream = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                example = "127.0.0.1:9090";
                description = "reverse_proxy target. null means DNS record only.";
              };
              caddy = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Generate a Caddy vhost for this host (requires upstream).";
              };
              extraConfig = lib.mkOption {
                type = lib.types.lines;
                default = "";
                description = "Extra Caddyfile directives for this vhost.";
              };
            };
          }
        )
      );
    };

    caddy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Auto-configure Caddy virtual hosts. Disable to manage Caddy yourself.";
      };

      dns = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Get real certificates via the ACME DNS-01 challenge instead of `tls internal`.";
        };
        provider = lib.mkOption {
          type = lib.types.str;
          default = "cloudflare";
          description = "Caddy DNS provider module name (the `dns <provider>` directive).";
        };
        plugin = lib.mkOption {
          type = lib.types.str;
          default = "github.com/caddy-dns/cloudflare@v0.2.4";
          description = "Go module for the provider, with a version. Pick a tag or commit from the plugin's repo.";
        };
        hash = lib.mkOption {
          type = lib.types.str;
          default = "sha256-QSiwKqKvSxhksWBF4/MlBOpyXba5xOQ2sRwA0R7399E=";
          description = "Fixed-output hash for the custom Caddy build. Build once and copy the real hash from the error.";
        };
        tokenVar = lib.mkOption {
          type = lib.types.str;
          default = "CF_API_TOKEN";
          description = "Environment variable the provider reads its API token from.";
        };
        resolvers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "1.1.1.1"
            "8.8.8.8"
          ];
          description = ''
            Public resolvers Caddy uses to check the challenge record. Needed because
            this machine's own resolver (Technitium) serves a local copy of the zone
            that never contains the temporary TXT record.
          '';
        };
      };

      tls = lib.mkOption {
        type = lib.types.lines;
        default =
          if dns.enable then
            ''
              tls {
                dns ${dns.provider} {env.${dns.tokenVar}}
                resolvers ${lib.concatStringsSep " " dns.resolvers}
              }
            ''
          else
            "tls internal";
        defaultText = "DNS-01 block if caddy.dns.enable, otherwise `tls internal`";
        description = "TLS directive(s) added to every generated vhost.";
      };
    };
  };

  config = lib.mkMerge [
    {
      sops.secrets."services/technitium-token" = { };

      systemd.services.technitium-zones = {
        after = [ "technitium-dns-server.service" ];
        wantedBy = [ "multi-user.target" ];
        # rerun the sync when the record set changes
        restartTriggers = [ (builtins.toJSON (builtins.attrNames cfg.hosts)) ];
        path = [ pkgs.curl ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          LoadCredential = "token:${config.sops.secrets."services/technitium-token".path}";
        };
        script = ''
          TECH_TOKEN=$(< "$CREDENTIALS_DIRECTORY/token")
          api=http://127.0.0.1:5380/api
          curl -fsS "$api/zones/create?token=$TECH_TOKEN&zone=${cfg.zone}&type=Primary" || true
          ${lib.concatMapStringsSep "\n" (h: ''
            curl -fsS "$api/zones/records/add?token=$TECH_TOKEN&zone=${cfg.zone}&domain=${h}.${cfg.zone}&type=A&ipAddress=${cfg.ip}&overwrite=true"
          '') (builtins.attrNames cfg.hosts)}
        '';
      };
    }

    (lib.mkIf cfg.caddy.enable {
      services.caddy.enable = true;
      services.caddy.openFirewall = true;
      services.caddy.virtualHosts = lib.mapAttrs' (
        name: h:
        lib.nameValuePair "${name}.${cfg.zone}" {
          extraConfig = ''
            ${cfg.caddy.tls}
            ${lib.optionalString (h.upstream != null) "reverse_proxy ${h.upstream}"}
            ${h.extraConfig}
          '';
        }
      ) caddyHosts;
    })

    (lib.mkIf (cfg.caddy.enable && dns.enable) {
      # secret file contents: CF_API_TOKEN=<token>  (variable name = caddy.dns.tokenVar)
      sops.secrets."services/caddy-dns-env".restartUnits = [ "caddy.service" ];

      services.caddy = {
        package = pkgs.caddy.withPlugins {
          plugins = [ dns.plugin ];
          hash = dns.hash;
        };
        environmentFile = config.sops.secrets."services/caddy-dns-env".path;
      };
    })
  ];
}
