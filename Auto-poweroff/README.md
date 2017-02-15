**Power off system at low battery automatically.**

To schedule it via cron:  
 - `chmod +x auto-poweroff.sh`.
 - `crontab -e`
 - Execute every minute - `* * * * * /path/to/auto-poweroff.sh`.
