To dump your GNOME config:

```
dconf dump /org/gnome/shell/extensions > config
```

To load the config file:

```
dconf load /org/gnome/shell/extensions/ < config
```
