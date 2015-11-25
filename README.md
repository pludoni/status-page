## Status Page script

by pludoni.

This is a simple generation script that fetches uptime information from a UptimeRobot account and displays that into a simple static HTML site.

This script is intended to run every 5 min., e.g. crontab:

```
*/5 * * * * * ruby /path/to/repo/generate.rb > /var/www/site/index.html
```


To run it, copy config.yml.example to config.yml and change the API key.
