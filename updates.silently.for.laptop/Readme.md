# Updates automatically and silently for Ubuntu
## For desktop and laptop

Set the script in "Startup Application" of Ubuntu.

What it does: display an icon in the notification area, check if battery high then update:
```
sudo apt update ; sudo apt full-upgrade -y ; sudo apt install -fy ; sudo apt autoclean ; sudo apt autoremove --purge -y
```

![screenshot1](https://user-images.githubusercontent.com/24923693/42731783-b51dbdca-8814-11e8-867d-12619cd1365d.png)
