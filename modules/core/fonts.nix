{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      material-icons
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
  };
}
