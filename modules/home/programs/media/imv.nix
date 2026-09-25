{ ... }:
{
  programs.imv = {
    enable = true;
    settings = {
      options = {
        fullscreen = false;
        upscaling_method = "linear";
        loop_input = true;
      };
      binds = {
        # navigation
        "h" = "prev";
        "l" = "next";
        "gg" = "goto 0";
        "G" = "goto -1";

        # zoom
        "+" = "zoom 2";
        "-" = "zoom -2";
        "=" = "reset";

        # pan
        "H" = "pan -50 0";
        "L" = "pan 50 0";
        "K" = "pan 0 -50";
        "J" = "pan 0 50";

        # rotation
        "r" = "rotate by 90";

        # misc
        "f" = "fullscreen";
        "x" = "close";
        "q" = "quit";
      };
    };
  };
}
