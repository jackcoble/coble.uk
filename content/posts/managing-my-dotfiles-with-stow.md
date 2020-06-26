---
title: "Managing my Dotfiles with Stow"
date: 2020-06-26T18:48:22+01:00
draft: false
---

To make my dotfiles easier to install, I first created a custom bash script to handle package installation, fonts and the dotfiles themselves. However, I have recently been in the mood to distro-hop again, so I find myself tinkering with different Linux distributions and wanting to get up and running as soon as possible. Limiting myself to a bash script that can only work on a certain distribution definitely isn't ideal.

In order to overcome this, I decided to do some research into [Stow](https://www.gnu.org/software/stow/). I had come across Stow a couple of years ago actually, but it seemed too complicated for me to get working on my system at the time. Looking back, I was totally wrong! Stow is actually dead simple to use!

But first, what is Stow?

> GNU Stow is a symlink farm manager which takes distinct packages of software and/or data located in separate directories on the filesystem, and makes them appear to be installed in the same place.

Basically, it's a program that makes a ton of symlinks...

## Adjusting my Dotfiles Directory

In order to make Stow work, my dotfiles directory structure needed a bit of modification. Previously, my scripts were put into a `bin` directory and my application configuration files were inside the `config` directory. Inside my script, I would manually add an entry to symlink the files in said directory. It become very tedious and inefficient quite quickly, especially as I was discovering more applications I wanted to incorporate into my workflow...

![Dotfiles Before](https://s.3xpl0its.xyz/2020-06-26/Screenshot-from-2020-06-26-18-57-33.png)

If I was to run the `stow` command right now under this directory structure, it would fail to install my dotfiles. To make it work, I had to follow this folder structure.

```
Application Name --> .config --> Application Config Files --> Application Name
```

As opposed to:

```
.config --> Application Name --> Application Config Files
```

Honestly, I have no idea why my dotfiles need to be configured in such a way, but the idea is that the folder represents the application you have configuration files for. Then inside the folder, you have the name of the folder which will be symlinked to your home directory (this will be the `.config` directory).

So after reworking my dotfiles directory structure, I ended up with something like this.

![Dotfiles After](https://s.3xpl0its.xyz/2020-06-26/Screenshot-from-2020-06-26-19-08-58.png)

## Installing my Dotfiles

As for installing my dotfiles, it couldn't get any easier! All I have to do is remove any files I don't want symlinked (such as the README) and run the following command. As for restoring the deleted file, I can just run `git stash` and everything is back to normal.

```
rm README.md
stow *
git stash
```

Here's a GIF of me doing the process from start to finish. It takes a matter of seconds, and before you know it, the dotfiles are installed!

![Stow](https://s.3xpl0its.xyz/2020-06-26/stow.gif)

## Wrap up

So, thats all it takes to manage your dotfiles. A bit of shuffling about here and there and then it's all done! I can definitely see myself to continually use this program as it handles my dotfiles extremely well. By design, Stow does not delete files, so you can't blame the software if something goes wrong! 😂

I guess that's the end of todays article...