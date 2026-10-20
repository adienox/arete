{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.loader.limine = {
    enable = true;
    maxGenerations = 8;

    secureBoot = {
      enable = true;
      autoGenerateKeys = true;
      autoEnrollKeys = {
        enable = true;
        extraArgs = [
          "--microsoft"
          "--firmware-builtin"
        ];
      };
    };
  };

  boot.plymouth.enable = true;
}
