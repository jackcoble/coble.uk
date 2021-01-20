---
title: "Speeding up Nextcloud with Redis"
date: 2020-09-24T12:19:47+01:00
---

I've been toying around with [Nextcloud](https://nextcloud.com/) *once again* with the ultimate goal to improve my workflow and not depend on any more services than I really have to. As I've only been playing around with Nextcloud though, and not using it full time, I decided to install it on my Raspberry Pi 4 (4GB RAM). For the most part, I've been pretty impressed. There are some great Nextcloud apps out there such as Music, Deck, Notes and many more. It is nice to have all this functionality under a single Nextcloud instance.

However, I have been experiencing some issues when it comes to dealing with a large amount of files on my instance. Nextcloud would feel quite sluggish and take a bit longer to complete operations on files that are accessed quite frequently. I've known about pairing Nextcloud and Redis together since the first time I installed Nextcloud a couple of years ago, but I never did it!

Just a heads up here, I run my Nextcloud (version 19) instance using Docker and the [official Nextcloud image](https://hub.docker.com/_/nextcloud), so if you are following along or have a manual installation, the configuration process might be slightly different for you. That said, let's begin!

# Spinning up a Redis container
The first step in making Nextcloud a bit more performant is to spin up a Redis container that will act as a cache to store our frequently accessed files. Although I use Docker to deploy my Nextcloud instance, I use Docker-compose to provision everything, so adding a new container is simply the case of adding a few lines to my `docker-compose.yml` file.

```yml
redis:
    image: redis
    restart: always
    volumes:
      - /opt/Nextcloud/redis:/data
```

I have chosen to create a volume for Redis to persist data inside the `/opt` directory, which is where the other volumes for my Nextcloud instance reside.

Additionally, in order for Redis to be usable by Nextcloud, I need link it. This essentially allows Nextcloud to reach the Redis container, even though they are in separate containers. I added the following to the `links` section of my Nextcloud service.

```yml
links:
    - redis
```

Just for reference, this is the section for my Nextcloud service.

```yml
nextcloud:
    image: nextcloud
    ports:
      - 8080:80
    links:
      - db
      - redis
    volumes:
      - /opt/Nextcloud/data:/var/www/html
    restart: always
```

# Editing the Nextcloud configuration to use Redis
Now that I have a Redis container waiting to be launched the next time I start Nextcloud, I first need to tell Nextcloud to make use of Redis. To do this, I opened up the `config.php` file I have located at `/opt/Nextcloud/data/config/config.php` and began editing!

First of all, I need to configure Nextcloud to use Redis for the distributed server cache. I did this simply by pasting in the snippet below.

```
'memcache.distributed' => '\OC\Memcache\Redis',
'redis' => [
     'host' => 'redis',
     'port' => 6379,
],
```

As my Redis instance is linked to Nextcloud, I can refer to it by its service name - `redis`.

And lastly, I decided to use Redis for file locking by adding in this one liner to my configuration file.

```
'memcache.locking' => '\OC\Memcache\Redis',
```

Tada! All done now! I was able to bring up my Nextcloud instance and other related containers by running `docker-compose up -d`, and now I have Redis acting as a performant caching layer! The upgrade was noticable right away as Nextcloud felt much more snappier.

# Verifying that Redis is storing data in memory
Although I noticed an increase in performance right away, I still wanted to make sure that Redis was doing its job by storing frequently accessed files in memory. To do this, I entered the Redis CLI and decided to list all the keys.

```bash
$ docker-compose exec redis redis-cli
$ KEYS *
```

Based upon the output, I would say that it is definitely working!

![Working](/img/2020-09-24/2020-09-24_13-06.png)