{
  programs = {
    shellcheck.enable = true;
    shfmt.enable = true;
  };

  settings.formatter.shfmt.options = [
    "-i"
    "2"
    "-ci"
    "-s"
  ];
}
