---
title: "Optimising my Nextcloud server"
date: 2020-09-24T17:44:23+01:00
draft: true
---

So after writing yesterday's post, I got to thinking about how I could further optimise my Nextcloud instance. To find out what I could do to optimise it, I decided to look at any "Security & setup warnings" and then got to work. 

# Security & setup warnings
![Optimisations](https://s.coble.uk/2020-09-24/nextcloud-optimisations.png)

If you wish to find out any security and setup warnings for yourself on your own instance, you can get to it by visiting Settings > Administration > Overview. Give it a few seconds to do a scan and it should return if you have any improvements to make!

Now unfortunately before I applied all of these optimisations, I forgot to take a screenshot of the warnings, so the one above is courtesy of someone online. It just so happened I had the same warnings as them. (Thanks again to whoever I nabbed this from!)

Here is a basic breakdown of what I need to fix in order to bring my instance up to scratch:
- Set a HSTS header to let all browsers know to only access my instance through HTTPS.
- Properly configure a redirect for CalDAV and CardDAV.

Fortunately, all of this can be done just by configuring my reverse proxy (Caddy), so lets get to it. First of all, I will address setting a HSTS header. Caddy makes this really simple for me to do.

```
nextcloud.coble.uk {
  header Strict-Transport-Security "max-age=15552000"
  
  reverse_proxy localhost:8080
}
```

Great! The first warning has now been resolved, onto configuring a redirect for CalDAV and CardDAV. Again, this is easily done with a couple of redirect rules.

```
nextcloud.coble.uk {
  header Strict-Transport-Security "max-age=31536000"

  redir /.well-known/carddav /remote.php/carddav 301
  redir /.well-known/caldav /remote.php/caldav 301
  
  reverse_proxy localhost:8080
}
```

I'll go ahead and restart my Caddy reverse proxy, login to Nextcloud and then visit the Overview page. Tada, all checks passed! :)

![No Warnings](https://s.coble.uk/2020-09-24/2020-09-24_18-07.png)

# Nextcloud Security Scan
If you are after a more in-depth breakdown about the security of your Nextcloud instance, you can run it through the [Nextcloud Security Scan](https://scan.nextcloud.com/). You put in the URL of your instance and then it will run a series of checks. Here is the outcome against my instance.

![Security Scan](https://s.coble.uk/2020-09-24/2020-09-24_18-13.png)

# Configuring background jobs
This is more of a performance optimisation, but an important one nonetheless. By default, Nextcloud relies on AJAX to execute background jobs. This means that for each page you visit on your Nextcloud instance, one task will be executed. This isn't really efficient, so we make use of the Cron scheduler instead to execute tasks at a set interval.

Because I am running the Docker version of Nextcloud however, this can be a bit problematic. I could add a Cron entry to my host system which executes the Cron command inside the Nextcloud Docker container, but I felt that I might as well look for a Docker container to handle it for me. To me it seems much cleaner to handle it that way.

Fast forward a few minutes of searching and I stumbled across this amazing Docker image by [rcdailey](https://github.com/rcdailey) called `nextcloud-cronjob`. You basically spin this up alongside your Nextcloud container and it will execute the Cron jobs for you every 15 minutes. Here is how it looks as a service in my Docker compose file.

```yaml
cron:
    image: rcdailey/nextcloud-cronjob
    restart: always
    depends_on:
      - nextcloud
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - NEXTCLOUD_CONTAINER_NAME=nextcloud
      - NEXTCLOUD_PROJECT_NAME=nextcloud
```

All I had to do was bring down my Nextcloud instance and then bring it up again with `docker-compose up -d`, and I had Cron scheduling working right away for Nextcloud. Hopefully I should be a bit of a performance gain now that AJAX isn't being used! :)

![Cron](https://s.coble.uk/2020-09-24/2020-09-24_18-24.png)

That is all for the optimisations in this post. Hopefully you found some of it useful! As time goes on, if I discover any more optimisations I will be sure to document them here and take screenshots before I apply them!