---
title: "Improving My Backup Solution"
date: 2020-05-19T22:42:30+01:00
---

For quite a while now, I've been a user of [Syncthing](https://syncthing.net). It is a peer-to-peer file synchronisation program that can synchronise files in real time. It has been an amazing application that makes up for a large part my workflow, and it has also allowed me to ditch cloud providers like Google Drive and Dropbox. In the past I have used Nextcloud, but I felt that it was too bloated for my needs - all I really do is need to sync files. But discussing why I chose Syncthing is for a future post.

Today's post is about how I can make secure backups of my Syncthing folders. I currently have a central Syncthing instance which is simply a Raspberry Pi 4 with an external drive attached to it. This instance maintains a collection of all the folders shared between my devices. Up until recently though, I had no proper backup strategy. If I was to accidentally recursively delete all the data throughout my folders, I would become a bit stuck as the changes would be propagated to my devices.

It turns out that I did just that. I was trying to write my own backup script using GPG and tar. It created the tar archive, encrypted it with GPG and then cleaned up the files once it had been uploaded to my [Minio](https://min.io/) server. Ok, so that must be all I need, right? Well, nope. For some reason, I figured it'd be a good idea to make a few modifications to the backup script. And unfortunately, I am no bash connoisseur, so I resulted to StackOverflow to help me with my needs. Long story short, the next time I'd run my script I'd end up deleting the tar archives as expected, but also my Syncthing folder.

You could say I got lucky though. Whilst my heart was racing, I remembered I had been testing my script elsewhere, and that it had produced a backup that was a few days old and hadn't been deleted. Now I was more anxious as to whether it would restore or not. Previous testing of the script resulted in corrupted tar archives for some reason. Anyway after waiting for a few hours to pull the backup, everything had restored! This was the eye-opener moment that I needed. The very next day I started to look at a proper backup solution - this is where [Restic](https://restic.net) comes in!

# Restic

![Restic Logo](https://s.3xpl0its.xyz/2020-06-08/restic.png)

Restic is a backup tool written in Go that is (in my eyes) extremely fast and efficient. It appealed to me as you can make backups to multiple storage mediums. Whether that is a local hard drive or an S3 storage server, Restic has support for a lot! My personal backup solution now evolves around 2 Minio servers. They are both self-hosted and running in Docker. One is hosted on another server on the local network, and the other is hosted on a VPS as an off-site backup. In the event of a mass deletion frenzy on my personal machines, I have hope that I can pull a recent backup from the local server. If something happened to that, then I am relying on my off-site backup.

If I have to restore, then I shouldn't lose much due to the amount of snapshots I keep:

* 12 hourly
* 7 daily
* 5 weekly
* 6 monthly

At most I guess I would lose about an hours worth of work if I was actually working on something.

This isn't really intended to be a guide, rather more of a documentation piece, but I'll talk about what you need to do if you want to follow along. The first step would be to install Restic on your machine and deploy yourself a Minio server. Now you can move onto the configuration of Restic. All you've got to do is create an environment variables file located at `~/.restic.env`.

```bash
export AWS_ACCESS_KEY_ID=minio
export AWS_SECRET_ACCESS_KEY="some_secure_password"
export MINIO_IP="<server_ip>"
export RESTIC_PASSWORD="some_secure_password_to_encrypt_backups"
```

> Make sure your password for `RESTIC_PASSWORD` is really strong and is backed up - if you lose it, you won't be able to decrypt your backups! Store it on paper in multiple locations or even keep it in your password manager (assuming your password for that is secure).

Once you've made that configuration file, be sure to load in the environment variables with `source ~/.restic.env`. Then you can go through the process of creating your remote S3 bucket through Restic:

```bash
restic -r s3:http://$MINIO_IP:9000/restic init
```

In order to make my life a bit easier, I decided to put the Restic commands into a shell script. This script simply contains all the commands that will create and prune the backups when necessary. Make sure you change the directory you want to backup.

```bash
#!/bin/sh
/usr/bin/restic -r s3:http://$MINIO_IP:9000/restic backup /directory_to_backup
/usr/bin/restic -r s3:http://$MINIO_IP:9000/restic forget --keep-hourly 12 --keep-daily 7 --keep-weekly 5 --keep-monthly 6 --prune
```

Onto the final bit for backups now, all you need to do is automate it. And to do that, we can just use Cron. After executing `crontab -e`, paste this at the bottom of the file:

```bash
@hourly . /location/of/.restic.env; /location/of/backup.sh
```

Again, make sure to change the location of these files. You can also change how often you want the backups to run as well as how many you'd like to keep. For me, I run them every hour, but tweak it to your liking.

Once you've got that all configured, you should soon see some backups/snapshots being made.

![Restic Snapshots](https://s.3xpl0its.xyz/2020-06-08/restic-snapshots.png)

When it comes to restoring from a backup, the [documentation](https://restic.readthedocs.io/en/latest/050_restore.html) outlines what you need to, and they'll do a better job of explaining it over me. 😅

# Conclusion
Anyway, thats my personal backup solution summarised in a single post. It works extremely well for my needs at the moment, so I don't plan on changing it any time soon.