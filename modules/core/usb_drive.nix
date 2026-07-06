{
  services.udisks2.enable = true;
  services.devmon.enable = true;
  environment.etc."udisks2/mount_options.conf".text = ''
    [defaults]
    vfat_defaults=uid=$UID,gid=$GID,shortname=mixed,utf8=1,showexec,flush,sync
    exfat_defaults=uid=$UID,gid=$GID,iocharset=utf8,errors=remount-ro,sync
    ntfs_defaults=uid=$UID,gid=$GID,windows_names,sync
  '';
}
