rec {
  paths = {
    dotFiles = "/home/nox/Documents/projects/arete";
    homeFiles = "${paths.dotFiles}/modules/home/files";
    scripts = "${paths.homeFiles}/scripts";
    notes = "/home/nox/Documents/notes";
  };
  fonts = {
    monospace = "Maple Mono NF";
    variable = "Readex Pro";
    emoji = "Apple Color Emoji";
  };
}
