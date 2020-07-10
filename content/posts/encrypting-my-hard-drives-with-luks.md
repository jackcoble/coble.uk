---
title: "Encrypting My Hard Drives With LUKS"
date: 2020-07-04T15:43:00+01:00
draft: false
---

Recently, I felt the need to encrypt one of the most important hard drives that I own. Honestly I'm surprised that I had gone without encryption on this drive for so long, but at least I am now taking the time to get it done. There were several steps I had to go through to ensure the drive was wiped so that any data is unrecoverable, and then checking that I had configured the encryption correctly.

To achieve all of this, I will be making use of LUKS (Linux Unified Key Setup). According to [Wikipedia](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup), LUKS is a disk encryption specification that was originally intended for Linux. It is based on tools such as `cryptsetup` and `dm-crypt`. Some of which I will be using throughout this article :)

## Securely wiping the hard drive
First of all, before I attempt to even encrypt this hard drive, I want to make sure that any previous data on it is gone forever. To achieve this, I used a Linux utilty called `scrub`.

```
# scrub -p dod /dev/sdb
```

The `-p` flag allows you to set the pattern you want to use to "destroy" your disk. In this case, I choose the DoD 5220.22-M data sanitisation method. If you are interested in how this method works, you can read the article I have found [here](https://www.lifewire.com/dod-5220-22-m-2625856).

Lastly, `/dev/sdb` is the disk that I intend to destroy. If you are unsure of the disks on your system, `lsblk` should assist you.

For me, I left the disk destroying process to take place overnight as I knew that it would take a long time. I did run this command on my Raspberry Pi, so in hindsight it probably would've been faster to use my laptop instead. It would have the same effect regardless of the device I used.

## Creating the Encrypted LUKS partition
If you have just freshly destroyed your hard drive, you are first of all going to need to create a new partiton for your drive. In my case, I used the `cfdisk` utility for this. I personally think that it is a fairly easy utility to use. Once that was done, I had a partition