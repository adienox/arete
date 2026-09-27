{ pkgs }:
{
  name,
  script,
  runtimeInputs ? [ ],
}:
{
  type = "app";
  program = "${
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile script;
    }
  }/bin/${name}";
}
