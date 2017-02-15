**Power off system at low power automatically.**

First ensure that you can hibernate non-interactively from cron without sudo:  
 - Execute `sudo visudo -f /etc/sudoers.d/custom`.
 - Enter the following into the buffer:  

 ```
 # Enable hibernation from cron
 anmol ALL=NOPASSWD: /bin/systemctl hibernate
 ```
  
Then, schedule it via cron:  
 - `chmod +x auto-poweroff.sh`.
 - `crontab -e`
 - Execute every minute - `* * * * * /path/to/auto-poweroff.sh`.
