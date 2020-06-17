---
title: "Neovim - Configuring my Text Editor"
date: 2020-06-17T19:30:35+01:00
draft: false
---

<!-- Access draft from this link: http://localhost:1313/2020/06/neovim-configuring-my-text-editor -->

I felt like I should document my Neovim setup for my personal reference in future and to also help others if they'd like to copy a few bits from my setup. As I feel like that this will be a constantly evolving post, I'll provide a table of contents for you to pick and choose what you want to read.

## Table of Contents
1. [Getting Started]({{< relref "#getting-started" >}})

### Getting Started
So as mentioned, I use Neovim as my text editor. It is a fork of Vim which is more modernised and aims to provide a better OOTB (out of the box) experience for users. This section will focus on installing Neovim, a plugin manager and installing a few basic plugins to get us started.

#### Installing Neovim
Packages for Neovim are available for the majority of mainstream operating systems such as Linux, MacOS and Windows. I use Linux, so I'll fetch the Neovim package using my package manager.

```bash
$ sudo apt install neovim
```

#### Configuring Neovim
Now that I've got Neovim installed, I can create a config directory for use with future settings and plugins.

```bash
$ mkdir ~/.config/nvim
$ touch ~/.config/nvim/init.vim
```

#### Installing and a Plugin Manager
We've got the basic configuration structure all sorted now, so we need to install our plugin manager. I'll be using [vim-plug](https://github.com/junegunn/vim-plug).

```
$ curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

The command above will put `plug.vim` into the autoload directory so it loads on the start of Neovim.

In order to keep plugin management a bit more tidier, I will manage the plugins in a seperate file.

```bash
$ mkdir ~/.config/nvim/vim-plug
$ touch ~/.config/nvim/vim-plug/plugins.vim
```

#### Installing Neovim Plugins
We'll now add some plugins to Neovim. Add the following to `~/.config/nvim/vim-plug/plugins.vim`.

```vim
call plug#begin('~/.config/nvim/autoload/plugged')

    " Language Syntax Support
    Plug 'sheerun/vim-polyglot'

    " File Explorer
    Plug 'scrooloose/NERDTree'

    " Auto pairs for '(' '[' '{'
    Plug 'jiangmiao/auto-pairs'

call plug#end()
```

Next, we need to source our plugins so that Neovim can recognise them. Add this line to your `~/.config/nvim/init.vim`.

```vim
source $HOME/.config/nvim/vim-plug/plugins.vim
```

Inside Neovim, execute the following to install the plugins.

```vim
:PlugInstall
```