---
title: "Upload - A Static File Server"
date: 2020-05-25T20:51:16+01:00
---

Back in June of last year, I felt the need to have a static file server. My reasoning behind wanting one was that I didn't want to hand over the control of my data to large corporations. I should say that it was around this time where I found out about Google and how much data they had on me. In short, it was concerning, so I felt the need to change this one step at a time.

This is where [Upload](https://github.com/jackcoble/upload) was born. I didn't want to rely on S3 or another service to host my files, so I wrote my own application and some helper scripts to do what I wanted to achieve. The first major release of Upload was quite literally a database that stored a unique identifier and then the file itself, but stored in a byte encoded format. When someone tried to retrieve the file, it would convert those bytes back into its original form and hardcode the result in the users browser using some sort of Base64 encoding. It was not very efficient as I was still learning some of the key concepts of Go at the time.

It was a botched solution at the time, I must admit, but it worked well for my personal use. For every request that was made, there would be a header which contained the "password" that gave the user permission to upload files through the exposed API. The script I wrote would allow me to run a command like the following to upload and access a file from the server:

```bash
upload file.png
```

This script worked wonders for me. I'd install and configure it on all of my systems, and then before I know it, I'd essentially have my own cloud that allowed me to quickly upload and share whatever file I wanted.

Moving on. The project gained a few stars on my Github page, and I felt that it wasn't meeting my needs as much anymore. By this time, I'd mostly ditched Google completely out of my life, and I had also taken down my Nextcloud instance. Additionally, I removed the need for a database and just served the files from a folder. I would use Nextcloud to share files from my phone by generating a publically accessible link. I had briefly mentioned in my one of my other posts that I stopped using Nextcloud due to it being too bloated for my needs, and that Syncthing didn't provide the option to share files publically as it is a P2P syncing solution for files. In order to fill this void of being unable to share files from my smartphone, I needed to make my Upload server smartphone friendly.

My most recent release of Upload has a couple of new features to accomodate for this:

* Cookie authentication as opposed to the custom authentication I'd implemented initially.
* A smartphone friendly user interface that I could upload files from.

These changes are what allowed me to make Upload usable on a smartphone. I can now visit the URL of where my Upload instance is hosted and then upload any file from my device! First of all I'd be greeted with an authentication page. I'd enter in my password and then a cookie would be stored on my device that is valid for a year.

![Authentication](https://s.3xpl0its.xyz/2020-06-08/authentication.png)

Once I have logged in, I am presented with a simplistic page that allows me to upload any file I want!

![File Upload](https://s.3xpl0its.xyz/2020-06-08/file-upload.png)

Some might say that it is a really simple solution, but it is all I needed. Yes, an AWS bucket could've been used here, but I felt like using the existing servers I've got for the year. If it helps me easily share files without the need of a cloud provider, then I am satisfied. Sorry for those who felt this might be a tutorial or an explanation post. If anything, it's more of a showcase of what I've been working on.