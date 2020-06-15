---
title: "Streaming From MinIO to MPV"
date: 2020-06-10T20:21:26+01:00
draft: false
---

If you've been reading my blog recently, you will find that I run a self-hosted instance of MinIO. At the moment, I have two instances. One to serve all my media such as Movies and TV shows, and then another one that acts as an off-site backup.

An issue that I've been having however is being able to stream from my MinIO instance into a video player of my choice. Now I can do this manually using the MinIO CLI (and I did for a little while), but it takes too much time just for a single episode of a TV show. My process of streaming media was the following:

```bash
$ mc ls minpi/tv-shows/Billions*
```
```
minpi/tv-shows/Billions/Season 1/Billions.S01E01.Pilot.mkv
...
```

I'd then take the output and pick an episode I wanted to watch. To then get a URL to view the episode, I would run the command below and copy the `Share` part of the output.

```bash
mc share download 'minpi/tv-shows/Billions/Season 1/Billions.S01E01.Pilot.mkv'
```
```
URL: http://192.168.0.68:9000/tv-shows/Billions/Season 1/Billions.S01E01.Pilot.mkv
Expire: 7 days 0 hours 0 minutes 0 seconds
Share: http://192.168.0.68:9000/tv-shows/Billions/Season%201/...
```

Lastly, to actually watch the episode, I would just take the URL and open it with MPV:

```bash
mpv "http://192.168.0.68:9000/tv-shows/Billions/Season%201/..."
```

This method works, but I find it far too tedious for my liking. The idea sparked this evening that I should attempt to write a *hacky* script, so I did exactly that! Ideally, I wanted something simple. If I could start a stream by doing a search based on the name of the TV show and an episode number, that would be awesome. Here is what I wanted to do:

```bash
./minio-mpv.sh Billions S01E01
```

## The script!

As I've also mentioned before, I am no Bash connoisseur. I put this script together using my basic knowledge and some help from StackOverflow. It is messy and likely has some bad ways of doing things, but it works! 😂

```bash
#!/bin/bash
# A simple script to stream from my Minio instance into MPV

# Set the Minio instance (same as mc cli)
HOST=minpi
BUCKET=tv-shows

# Setting the instance
INSTANCE=$HOST/$BUCKET

# Find a TV show based on the name and episode number
# e.g. mc find minpi/tv-shows --name "Billions*S04E11*"
EPISODE=$(/usr/bin/mc find $INSTANCE --name "$1*$2*")
if [ -z "$EPISODE" ]; then
    echo "Episode not found for $1"
else
    echo "Found an episode for $1 - $2"
fi

# Now I need to share the file now that we've got the path for it
URL=$(/usr/bin/mc share download "$EPISODE" | grep -E "Share:" | sed 's/Share: //g')

# Lastly, launch MPV!
/usr/bin/mpv "$URL"
```

If you would like to use it, then you are more than welcome to! Just make sure to change out the variables I've got set at the top. :)

### Usage
Usage is quite simple, its the same as how I described earlier on. If you have everything set correctly and run the command below, a stream should begin.

```bash
./minio-mpv <tv-show> <season-ep> # Billions S01E01
```

![MPV](https://s.3xpl0its.xyz/2020-06-10/mpv.png)

Tada, it works! 🎉 It might not be perfect, but it'll do for now. Over time I might improve the script to make it a bit more robust as there are still some issues with certain file names. If I can do that, then I'll also put it on my GitHub.

That concludes this article I guess, but if you have any questions, feel free to visit my [main website](https://3xpl0its.xyz) and contact me through one of the social media channels I've got listed.