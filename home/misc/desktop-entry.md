# Annoying Desktop Entries

There will be some apps that don't follow the NixOS way of putting the `.desktop` entry,
or app lanuchers that ignore the home-manager's `xdg-desktopEntries`.  
Some notable offenders I have experienced are `rofi` and some `waydroid`'s google apps.  
If you're experiencing this, you can use the following code.
It creates a symlink on `~/.local/share/applications`,
which has the highest priority to decide if an application should show up on an app lanucher or not.

```bash
 { lib, ... }:

let
  annoyingApps = [
    # The name of the desktop entry
    "rofi"
    "rofi-theme-selector"
    "waydroid.com.android.vending"
    "waydroid.com.google.android.apps.messaging"
    "waydroid.com.google.android.contacts"
    "waydroid.com.google.android.apps.restore" 
  ];

  hiddenDesktopContent = name: ''
    [Desktop Entry]
    Type=Application
    Name=${name}
    Exec=true
    NoDisplay=true
    Hidden=true
  '';
in
{
  home.file = lib.listToAttrs (map (name: {
    name = ".local/share/applications/${name}.desktop";
    value = { text = hiddenDesktopContent name; };
  }) annoyingApps);
}
```
