---
title: "Migrating From Traefik to Caddy"
date: 2020-06-08T17:12:51+01:00
---

So for approximately 2 years now, Traefik had been my go-to reverse proxy and load balancer for all my projects due to it working so well with Docker.

But first, what is Traefik? [Traefik](https://traefik.io) (pronounced traffic) is a reverse proxy and load balancer for HTTP applications. It works with technologies such as Kubernetes, Docker, Docker Swarm and AWS are just a few to mention. You can take a look at the rest of the providers [here](https://docs.traefik.io/providers/overview). For my usecase, I exclusively used it with Docker, but I did tinker with Kubernetes - it wasn't for me.

I should add that with my Traefik + Docker reverse proxy setup, I had used Cloudflare for both a DNS and SSL certificate provider.

## Why did I want to change from Traefik to Caddy?

Well, one of the biggest motivations was to escape the grasp of Cloudflare. I had been using them to "secure" multiple websites for a couple of years now, and I use that term lightly as website traffic was simply being routed through them as a third party. Also, back in July of last year there was a long outage that was caused by a bad software deployment. This was not ideal as a lot of websites (including mine) were unaccessible for an extended period of time. Lastly, I'm trying to de-Google my life. In other words, I am trying to reduce my dependence on external services to handle things for me.

## Why don't you just use Traefik with LetsEncrypt?

To sum it up quickly, Traefik was a massive pain to configure! I was still running v1 even though v2 was released and I honestly dreaded the day when I knew I'd have to upgrade. Just setting it up to work with Cloudflare took me about a day on it's own, and I don't have that sort of time now to do it again, but using LetsEncrypt instead. From setting up Traefik to adding in entries to the `traefik.toml` configuration file, it was just too time consuming.

Also over time, I didn't see any benefits to using Traefik over other reverse proxies like Nginx. My websites were deployed in Docker containers and I just needed to reverse proxy them. I didn't need any of its features such as metrics and auto discovery etc - I could just use external providers for that if I wanted to.

Moving on, I came across Caddy whilst it was still in version 1. I had used it in the past to reverse proxy a couple of applications on my local network, but nothing too extreme. They had a total rewrite of the application and released a production-ready version 2 at the start of last month actually! The configuration syntax was a little different, but I found the documentation quite informative and quickly found what I needed.

## Why did I choose Caddy?

The thing that drew me to [Caddy](https://caddyserver.com) is how easy it was to get running. The configuration syntax was super simple and it just worked. Oh, and it uses LetsEncrypt right out of the box which was a massive bonus! I also recently just discovered that it has a built in web server, which has come in super handy to serve some of my websites! No more Nginx containers needed for static websites :)

## How am I running Caddy?

I currently run Caddy inside a Docker container. Again, deployment was super simple for that using docker-compose. Here's the file I put together. It's as simple as running `docker-compose up -d` and you should be good to go.

```yml
version: '3.3'
services:
  caddy:
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - '$PWD/Caddyfile:/etc/caddy/Caddyfile'
      - '$PWD/static:/static'
      - '$PWD/caddy_data:/data'
    image: caddy
```

I currently have ports 80 and 443 exposed to the container, but you might want to set the networking mode to host instead. It's totally up to you. I also have volumes for the `Caddyfile` itself, a static content folder that I use to serve a couple of websites and then a folder for any data that Caddy needs to function (the LetsEncrypt certificates).

And here is my Caddyfile for my personal websites.

```
# =================
# Personal Services
# =================

# Personal website
3xpl0its.xyz {
  root * /static/3xpl0its.xyz
  try_files {path} /index.html
  file_server
  encode zstd gzip
}

# Blog
blog.3xpl0its.xyz {
  root * /static/blog
  file_server
  encode zstd gzip
}
```

Both my personal website and blog are static, so I decided to make use of Caddy's built-in file server feature to serve them. If you want to make use of the reverse proxy feature, then its as simple as putting this in your configuration.

```
# Minio server
m.3xpl0its.xyz {
  reverse_proxy * localhost:9000
}
```

Restart the Docker container with `docker-compose restart` and then Caddy will go off to fetch LetsEncrypt certificates for your domains assuming you've got them setup correctly.

# The end!

So that brings us to the end of my journey when it came to migrating from Traefik to Cloudflare. I'm really happy with how it's turned out and I see myself continuing to use this setup for the forseeable future!