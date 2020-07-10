---
title: "Updating My SoloKey"
date: 2020-06-15T16:19:48+01:00
draft: false
---

<!-- Image of SoloKey -->
![SoloKey](https://s.3xpl0its.xyz/2020-06-15/IMG_20200316_153945.jpg)

Its been a few months since I first purchased my SoloKey. The version I have right now is the Solo Tap (USB-A + NFC). I haven't tested the NFC part yet, so I'm not sure if that functionality is actually working.

In general, I would say my experience with using the hardware key has been amazing. I was originally attracted to the SoloKey as all aspects of it are open source - all the way from the hardware and through to the firmware that actually runs on it. And whenever possible, I try and use the SoloKey as my second factor authentication method on the websites which support it.

When it came to updating the key earlier on today, I tried to use the [Solo Web updater](https://update.solokeys.com/), but it has apparently been deprecated for quite a while. Regardless of that fact, I gave it a go and the update process failed - kind of expected that to happen.

So now I need a way of updating my SoloKey. That's when I stumbled across the [solo-python](https://github.com/solokeys/solo-python) library. It must be my lucky day or something, but a quick `pip3 install solo-python` actually worked on the first try!

## The update process

Updating through the CLI is pretty easy. You just need to put your SoloKey into "bootloader" mode. That can be achieved by holding down the button whilst plugging it into your computer for two seconds. If it starts blinking between yellow and green, then you've probably done it correctly! Here's a GIF of what it should look like.

![SoloKey Blinky](https://s.3xpl0its.xyz/2020-06-15/blinky.gif)

Now that you are in "bootloader" mode, you need to fire up your terminal and execute the following command.

```bash
$ solo key update
```

You'll likely see some output on your screen. I wouldn't suggest unplugging your SoloKey in this period as you might brick it.

```
Not using FIDO2 interface.
Wrote temporary copy of firmware-4.0.0.json to /tmp/tmp4s_qmhmq.json
sha256sums coincide: b1822355eb1151f004cd7886ba338deee8c84488299ec3a8e5448a1057cd8455
using signature version <=2.5.3
erasing firmware...
updated firmware 100%             
time: 7.58 s
bootloader is verifying signature...
...pass!

Congratulations, your key was updated to the latest firmware version: 4.0.0
```

If you see the congratulations message at the end, then you updated your SoloKey correctly! I found the update process really easy overall. Normally I encounter issues with the `pip` package manager itself or something to do with `udev` rules on my system, but today it was painless.