# Guide to Set Up Waydroid  

Since there is no way to decalratively set up waydroid,
this readme will be a basic guide.

```bash  
sudo waydroid init
waydroid session start
```  

We need an arm translation layer for most apps to work  

```bash
nix shell github:nix-community/NUR#repos.ataraxiasjel.waydroid-script -c sudo waydroid-script
Android 13 -> Install -> libndk (or libhoudini) 
```

