{ inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "default" ];
  };

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    profiles.default = {
      settings = {
        "zen.tabs.show-newtab-vertical" = false;
        "zen.tabs.vertical.right-side" = true;
        "zen.urlbar.behavior" = "float";
        "zen.view.compact.enable-at-startup" = false;
        "zen.welcome-screen.seen" = true;
        "zen.workspaces.continue-where-left-off" = true;

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        "browser.startup.homepage" = "https://home.kyle-kwong.com";
        "browser.translations.enable" = false;
        "browser.translations.neverTranslateLanguages" = "zh-Hant";
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            "widget-overflow-fixed-list" = [ ];
            "unified-extensions-area" = [
              "sponsorblocker_ajay_app-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action" # Return YouTube Dislike
              "enhancerforyoutube_maximerf_addons_mozilla_org-browser-action"
              "_58204f8b-01c2-4bbc-98f8-9a90458fd9ef_-browser-action" # BlockTube
            ];
            "nav-bar" = [
              "urlbar-container"
              "unified-extensions-button"
            ];
            "toolbar-menubar" = [ "menubar-items" ];
            "TabsToolbar" = [
              "tabbrowser-tabs"
              "ai-window-toggle"
              "smartwindow-group-tabs-button"
            ];
            "vertical-tabs" = [ ];
            "PersonalToolbar" = [
              "import-button"
              "personal-bookmarks"
            ];
            "zen-sidebar-top-buttons" = [ "zen-toggle-compact-mode" ];
            "zen-sidebar-foot-buttons" = [
              "downloads-button"
              "zen-workspaces-button"
              "logins-button"
            ];
          };
          currentVersion = 26;
        };
      };

      mods = [
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
        "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "b51ff956-6aea-47ab-80c7-d6c047c0d510" # Disable Status Bar
        "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
      ];

      pinsForce = true;
      pinsForceAction = "remove";
      pins = {
        "nix-config" = {
          id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890";
          url = "https://gitlab.com/kylekwong/nix-config";
          position = 100;
          isEssential = true;
        };
      };

      userChrome = ''
        #urlbar-zoom-button,
        #zen-copy-url-button,
        #zen-page-actions-copy-url,
        #pageAction-urlbar-_test-copy-link,
        #pageAction-urlbar-copy-url,
        .urlbar-page-action[action-id="copy-url"],
        .urlbar-page-action[action-id="zen-copy-url"],
        .titlebar-button.titlebar-close,
        .titlebar-close,
        #titlebar-close,
        #back-button,
        #forward-button,
        #stop-reload-button,
        #reload-button,
        #stop-button {
          display: none !important;
        }
      '';
    };
  };
}
