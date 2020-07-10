---
title: "Configuring Wi-Fi With ConnMan"
date: 2020-06-21T16:11:05+01:00
draft: false
---

On my Void Linux machines, it can sometimes be problematic to connect to a Wi-Fi network. I'm also not a fan of wpa_supplicant, so I went after an alternative, which happens to be [ConnMan](https://docs.voidlinux.org/config/network/connman.html).

## Installing ConnMan
1. Using the XBPS package manager, install ConnMan.
```bash
$ sudo xbps-install -Sy connman
```

2. Disable wpa_supplicant and dhcpcd as they are conflicting services.
```bash
$ sudo rm /var/service/wpa_supplicant /var/service/dhcpcd
```

3. Enable the ConnMan service
```bash
$ sudo ln -s /etc/sv/connmand /var/service
```

## Connecting to a Wi-Fi network
Here's a walkthrough of how to connect.
```bash
$ sudo connmanctl
```
```
connmanctl> enable wifi
Enabled wifi

connmanctl> scan wifi
Scan completed for wifi

connmanctl> services
* AO Access-Point wifi_123abc_456def_managed_psk
     Access-Point2 wifi_XXXXXX_XXXXXX_managed_psk
     Access-Point3 wifi_XXXXXX_XXXXXX_managed_psk

connmanctl> agent on
Agent registered

connmanctl> connect wifi_XXXXXX_XXXXXX_managed_psk
Agent RequestInput wifi_XXXXXX_XXXXXX_managed_psk
  Passphrase = [ Type=psk, Requirement=mandatory ]

Passphrase? **********
Connected wifi_XXXXXX_XXXXXX_managed_psk

connmanctl> quit
```