**Power off or suspend system at low battery automatically.**

Usefull if the OS installed can't do it automatically.

To schedule it via cron:  
 - `chmod +x auto-poweroff.sh`
 - `crontab -e`
 - Execute every minute - `* * * * * /path/to/auto-poweroff.sh`
