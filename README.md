## Status Page script

by pludoni.

This is a simple generation script that fetches uptime information from an (free) [UptimeRobot](https://uptimerobot.com) account and displays that into a simple static HTML site.

This script is intended to run every 5 min., e.g. crontab.

### Installation

### 1. Add all your hosts into Uptimerobot Dashboard

Also create and note your API Key (found in "My Settings" -> "Api settings" -> "Main API key")

### 2. Create a http static website, e.g. vhost with your webserver

### 3. Checkout the code + Install dependencies

Needs Ruby >=2

```
git clone https://github.com/pludoni/status-page.git
cd status-page
bundle install
```


### 4. Copy config and adjust to your needs:

```
cp config.yml.example config.yml
vim config.yml
```

### 4. Copy over CSS and Images:

```
cp -r materialize.min.css images/ /var/www/status.HOST/htdocs
```

Bonus points: replace the host images in /images with your own hosts (Name of the file is hostname without top level domain and www)

### 5. Run to make sure it works:

```
ruby generate.rb /var/www/status.HOST/htdocs/index.html
```

### 5. Add Crontab

```
*/5 * * * * /bin/bash -l -c 'cd ~/status-page && ruby generate.rb /var/www/status.HOST/htdocs/index.html'
```


