**Power off system at low battery automatically.**

To schedule it via cron:  
 - `chmod +x auto-poweroff.sh`.
 - `crontab -e`
 - Execute every minute - `*/1 * * * * /path/to/auto-poweroff.sh`.
