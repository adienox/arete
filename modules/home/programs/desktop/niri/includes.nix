{ config }:
[
  {
    include = {
      _args = [ "animations.kdl" ];
      _props.optional = true;
    };
  }
]
++ (
  if config.programs.dank-material-shell.enable then
    map
      (file: {
        include = {
          _args = [ "dms/${file}" ];
          _props.optional = true;
        };
      })
      [
        "alttab.kdl"
        "binds.kdl"
        "colors.kdl"
        "cursor.kdl"
        "input.kdl"
        "layout.kdl"
        "outputs.kdl"
        "windowrules.kdl"
        "wpblur.kdl"
      ]
  else
    [ ]
)
