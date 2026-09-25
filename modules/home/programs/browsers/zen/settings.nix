{ vars, ... }:
{
  programs.zen-browser.profiles.default.settings = {
    "zen.folders.search.hover-delay" = 500;
    "zen.workspaces.continue-where-left-off" = true;
    "zen.view.compact.hide-tabbar" = true;
    "zen.urlbar.behavior" = "float";
    "zen.welcome-screen.seen" = true;
    "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true; # Restore pins to original URL, not last visited
    "zen.workspaces.separate-essentials" = false; # Show essential pins in all workspaces
    "zen.glance.activation-method" = "ctrl";
    "zen.glance.animation-duration" = 150;
    "zen.widget.linux.transparency" = true;
    "zen.view.grey-out-inactive-windows" = false;
    "browser.tabs.allow_transparent_browser" = true;
    "zen.workspaces.show-workspace-indicator" = false;

    "devtools.debugger.remote-enabled" = true;

    # Ctrl Tab Mod
    "psu.better_ctrltab.roundness" = "12px";
    "psu.better_ctrltab.preview_favicon_size" = "0px";

    # Custom UI Font Mod
    "theme.custom_uifont.custom" = vars.fonts.variable;
    "theme.custom_uifont.default" = "Custom";

    # Better Find Bar Mod
    "theme.better_find_bar.vertical_position" = "top";

    # SuperPins Mod
    "uc.remove-sidebar-scrollbar" = true;
    "uc.essentials.transition-bg" = true;
    "uc.essentials.box-like-corners" = true;
    "uc.tabs.show-separator" = "essentials-shown";

    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.aboutConfig.showWarning" = false;
    #"browser.uiCustomization.state" = builtins.readFile ./uiState.json;

    # custom
    "nox.custom.urlblur" = true;
    "nox.custom.glance" = true;
    "nox.custom.coloredcontainertab" = true;
    "xpinstall.signatures.required" = false;

    # Natural Scrolling form smoothfox.js
    "apz.overscroll.enabled" = true;
    "general.smoothScroll" = true;
    "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
    "general.smoothScroll.msdPhysics.enabled" = true;
    "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;
    "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
    "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
    "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
    "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
    "general.smoothScroll.currentVelocityWeighting" = "1";
    "general.smoothScroll.stopDecelerationWeighting" = "1";
    "mousewheel.default.delta_multiplier_y" = 300;
  };
}
