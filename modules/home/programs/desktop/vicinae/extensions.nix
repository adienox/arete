{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  extensions = inputs.vicinae-extensions.packages.${system};
  mkRayCastExtension = inputs.vicinae.lib.${system}.mkRayCastExtension;
  mkExtension = inputs.vicinae.lib.${system}.mkVicinaeExtension;
in
{
  programs.vicinae.extensions =
    with extensions;
    [
      bitwarden
      nix
      power-profile
      pulseaudio
      process-manager
      wifi-commander
      niri
    ]
    ++ (
      let
        raycastRev = "3c654737b0d566d3103fcdf72221a9f34664bdf2";
        adienoxRev = "856bd8bcacf0c980feb18f9dd5d74901ffc30a88";

        mkRayCastExt =
          { name, hash }:
          mkRayCastExtension {
            inherit name;
            rev = raycastRev;
            sha256 = hash;
          };

        mkAdienoxExt =
          { name }:
          mkExtension {
            inherit name;
            version = "0.0.1";
            src =
              pkgs.fetchFromGitHub {
                owner = "adienox";
                repo = "vicinae-extensions";
                rev = adienoxRev;
                sha256 = "sha256-7Mn+nH5S2WasoYlxSiWkMn/sWcb/KlXKbLjvZnxdRR0=";
              }
              + "/${name}";
          };
      in
      [
        (mkRayCastExt {
          name = "spotify-player";
          hash = "sha256-V/CY8/0IHb38JmQhzLuRa6AHnnRk8O9G0zVBv9W/tiw=";
        })
        (mkRayCastExt {
          name = "tailscale";
          hash = "sha256-RX2SyyPvG5RVxANGXymYIXEFzZq3koEcxWmPQcrPVig=";
        })
        (mkRayCastExt {
          name = "freshrss";
          hash = "sha256-vKT6G0QcP5/A/jKPS803uCTPWwgvDNwS1+g5oAqGn+0=";
        })
        (mkAdienoxExt { name = "fmhy"; })
        (mkAdienoxExt { name = "home-assistant"; })
        (mkAdienoxExt { name = "org-todos"; })
      ]
    );
}
