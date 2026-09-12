# Home-manager profiles for different usage scenarios
#
# Profiles allow you to easily switch between different configurations by
# enabling/disabling specific module groups based on your current needs.
#
# Usage in flake.nix:
#   mkHome { system = "x86_64-linux"; profile = "personal"; }
#
# Available profiles:
#   - personal:  Full configuration with all development tools and desktop apps
#   - work:      Minimal work setup focusing on productivity tools
#   - minimal:   Bare essentials only for testing or minimal systems
#
# To create a new profile:
#   1. Create a new .nix file in modules/home/profiles/
#   2. Define which modules to enable (set options.modules.*.enable)
#   3. Reference it from lib/default.nix mkHome function

{ }
