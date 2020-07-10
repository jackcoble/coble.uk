---
title: "Making Use of the SSH Config"
date: 2020-05-20T19:29:17+01:00
---

As of 2 days ago, I had been relying on my own memory, bash history and my password manager to get the IPs of servers that I need to SSH in to. This method works great for some, but now I am struggling to remember IP addresses and whatnot. Additionally, my bash command history isn't available on all of my machines, so searching up previous ssh commands is a problem too.

This is where the almighty SSH config comes in! I'd known about the SSH config file ever since I got properly into Linux some years ago now, but I had never actually made use of it, because I never felt I would need to. But now my server collection has grown and its probably wise to make use of it. Before I got to using it though, I decided to find some random name generator online and change the hostnames of my servers, just for consistency sake when writing my config file.

The configuration file is really simple to be honest. Just create an empty file in `~/.ssh/config` and open it in a text editor of your choice. Here's a rough breakdown of what an entry would look like.

```
Host shadow
    HostName 192.168.0.12
    User jack
    Port 59513
```

The entry above is for one of the machines on my local network. I execute the command `ssh shadow` and then boom! I'm SSH'd into that machine. No need to remember IP addresses, usernames or different SSH ports as that is already defined in the config.

An issue I faced though was how do I keep this in sync? I could use my public dotfiles repository on GitHub, but I didn't feel like exposing the IP addresses, usernames and SSH ports of my servers to the public. Instead, I decided to make use of an existing solution I've got setup already, and that is Syncthing. I dumped the config file in a folder, and then created a symlink to my `.ssh` directory.

```bash
ln -s /home/jack/Syncthing/Documents/Keys/SSH/config ~/.ssh/config
```

I repeat this command on all my other devices that use Syncthing and any changes I make to the config are synced between them. Perfect!