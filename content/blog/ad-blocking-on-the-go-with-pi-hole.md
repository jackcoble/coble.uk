---
title: "Ad-blocking on the go with Pi-hole"
date: 2020-07-25T18:00:23+01:00
draft: false
---

![Pi-hole](https://s.3xpl0its.xyz/2020-07-25/Pi-hole.jpg)

It has been quite a while since my last post, but today I wanted to share with you an awesome solution that allows you to use your [Pi-hole](https://pi-hole.net/) instance from anywhere in the world, and allow for ad blocking on the go. But first, what is Pi-hole?

> Pi-hole is a Linux network-level advertisement and Internet tracker blocking application which acts as a DNS sinkhole and optionally a DHCP server, intended for use on a private network. - [Wikipedia](https://en.wikipedia.org/wiki/Pi-hole).

Just for a bit of context, I have been using Pi-hole on my home network for all of my devices, but have always struggled to get it paired with OpenVPN so that I can use it when I am roaming. Even after reading all of the documentation, I for some reason struggled on getting it working with Docker.

This was where the idea sparked to make use of [WireGuard](https://wireguard.com) as an alternative solution to OpenVPN. WireGuard is a VPN tunnel that is lightweight, fast and makes use of the latest cryptography. When comparing it to OpenVPN, it is definitely faster and it also consumes less battery power on my smartphone. It might warrant a separate post on its own in the future if anyone is interested.

## Docker all the things!

The great part about this setup is that a single Docker compose file can handle everything for us as there are images available for both WireGuard and Pi-hole. Below is the compose file that I put together. It is currently running on my server with no issues so far. Of course, please change the environment variables where necessary.

```yaml
version: "3"
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    environment:
      TZ: 'Europe/London'
      WEBPASSWORD: 'SUPER_SECURE_PASSWORD'
    volumes:
       - './pihole/etc-pihole/:/etc/pihole/'
       - './pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/'
    dns:
      - 127.0.0.1
      - 1.1.1.1
    networks:
      pihole:
        ipv4_address: 10.13.13.255
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
  wireguard:
    image: linuxserver/wireguard
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - SERVERURL=SERVER_IP_OR_DOMAIN
      - SERVERPORT=51820
      - PEERS=1
      - PEERDNS=auto
    volumes:
      - ./wireguard/config:/config
      - ./wireguard/lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    networks:
      - pihole
    dns:
      - 10.13.13.255
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped

networks:
  pihole:
    ipam:
      driver: default
      config:
        - subnet: 10.13.13.1/16
```

I decided to run Pi-hole and WireGuard in Docker containers as I can limit them from interacting with the other services on my server. In this case, Pi-hole is networked to WireGuard and that is all.

The beauty of this is that I don't need to publically expose my Pi-hole instance. Additionally, no other services running on my server can be accessed from my WireGuard VPN, which puts me at ease if the device I use WireGuard with was compromised and the attacker gained access to the VPN tunnel - they wouldn't be able to do very much other than experience ad-blocking on the go.

In my configuration, I have decided to set Pi-hole's IP address to `10.13.13.255` - the last IP address on the network. I also kept the default DNS so I don't accidentally break anything - though once up and running, the DNS provider can be changed anyway through the web UI. It is important to keep the DNS record of `127.0.0.1` as that is the Pi-hole instance itself.

If you wish to have more than 1 connection to your WireGuard VPN, I suggest incrementing `PEERS` to your ideal figure. I share this VPN with someone else, so I decided to increment it to `PEERS=2`. It can be adjusted in the future too if you want to create more connections. Just change the number and restart the WireGuard container.

Lastly, there is need to expose any ports of the Pi-hole instance as it is networked to the WireGuard VPN tunnel operating on port 51820 over UDP. On your server this is the only port you would need to open.

Once configured to your liking, you can start Pi-hole and WireGuard with a single command.

```bash
$ docker-compose up -d
```

## Connecting to WireGuard
Great, so you should now have Pi-hole and WireGuard up and running if you are following along. All you need to do now is actually connect to your VPN tunnel. Fortunately, WireGuard makes this very easy for us! First of all, go ahead and install the WireGuard application for [Android](https://f-droid.org/en/packages/com.wireguard.android/) or [iOS](https://apps.apple.com/gb/app/wireguard/id1441195209). You now need to go to your server and execute the following command.

```bash
$ docker-compose exec wireguard /app/show-peer <peer_number>
```

There should be a QR code outputted to your terminal. You can now go ahead and open the WireGuard app on your smartphone and scan in the QR code. All the details for your VPN tunnel should be filled in.

![Scan QR Code](https://s.3xpl0its.xyz/2020-07-25/signal-2020-07-25-185138.jpg)

All you've got to do now is give it a name, hit save and then adjust the toggle to "on"!

![Toggle](https://s.3xpl0its.xyz/2020-07-25/signal-2020-07-25-185743.jpg)

To check that everything is working, you can visit `http://10.13.13.255` (or whatever you set Pi-hole's IP address too), and you should be greeted with Pi-hole's dashboard. The ad-blocking should begin!

![Dashboard](https://s.3xpl0its.xyz/2020-07-25/signal-2020-07-25-190246.png)

## Conclusion
So you now have a DNS ad-blocker that can be accessed anywhere on the go! Without WireGuard, I don't think I would ever achieve such a great solution, so kudos to the WireGuard developers for making my life easy! 