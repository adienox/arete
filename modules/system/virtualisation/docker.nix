# Docker is available on every profile (workstations and servers).
{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
