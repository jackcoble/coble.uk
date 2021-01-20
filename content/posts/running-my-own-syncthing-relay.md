---
title: "Running my own Syncthing relay"
date: 2020-10-04T20:16:25+01:00
draft: false
---

[Syncthing](https://syncthing.net/) is an open source and decentralised file synchronisation tool that I have been using for quite some time now to replace traditional cloud providers such as Google Drive, iCloud and OneDrive. I never required the file sharing features of a cloud provider, so Syncthing has been a great fit for me!

As Syncthing has been critical for my workflow, I started at looking at ways I could give back at the project. I initially made a small donation, but I still felt that wasn't enough. This was where the thought of running a relay came into my head. After all, I do have a VPS on hand with unlimited bandwidth...

But first, what is a Syncthing relay? By default, Syncthing will try to establish a direct connection between two devices. However, if this is not possible, a relay will be used instead. Relays are much slower compared to a direct connection between two devices, but they are used as a last resort. I should add that the data transferred through a relay is also encrypted. An operator will not be able to snoop on your files whilst in transit to your other devices.

The documentation for Syncthing relays can be found [here](https://docs.syncthing.net/users/strelaysrv.html).

# Easy deployment with Docker

Since the majority of my services are deployed with Docker, I wanted the Syncthing relay to be deployed with it too! Originally I found a Docker image created by [Kyle Manna](https://github.com/kylemanna), but the Syncthing version being used was a bit dated and there also wasn't instructions for Docker-compose deployments, which might be useful for some who are unfamiliar with it.

To solve this, I forked the repository, updated the Dockerfile and pushed a new image to Docker Hub. For those that are interested, my fork can be found [here](https://github.com/jackcoble/docker-syncthing-relay).

Before deploying, I also ensured that ports `22067, 22070 TCP` were opened on my firewall. I like deploying my services with Docker-compose, so here is my file in use.

```yaml
version: '3.3'
services:
    syncthing-relay:
        ports:
            - '22067:22067'
            - '22070:22070'
        image: jackcoble/syncthing-relay
        command: "-provided-by=https://coble.uk" # optional
```

And before I know it, I have a Syncthing relay that is operational! By default, the relay will automatically join the other pool of relays. If you wish to keep it private, you can do so by declaring an [empty pools list](https://docs.syncthing.net/users/strelaysrv.html#cmdoption-pools) in your additional options.

![Relay page](/img/2020-10-04/relay-page.png)