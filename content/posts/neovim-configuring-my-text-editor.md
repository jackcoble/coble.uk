---
title: "Neovim - Configuring my Text Editor"
date: 2020-06-17T19:30:35+01:00
draft: false
---

<!-- Access draft from this link: http://localhost:1313/2020/06/neovim-configuring-my-text-editor -->

![Neovim Logo](https://s.3xpl0its.xyz/2020-06-17/Neovim-logo.svg.png)

I felt like I should document my Neovim setup for my personal reference in future and to also help others if they'd like to copy a few bits from my setup. As I feel like that this will be a constantly evolving post, I'll provide a table of contents for you to pick and choose what you want to read.

## Table of Contents
1. [Getting Started]({{< relref "#getting-started" >}})
2. [The Basics]({{< relref "#the-basics" >}})

## Getting Started
So as mentioned, I use Neovim as my text editor. It is a fork of Vim which is more modernised and aims to provide a better OOTB (out of the box) experience for users. This section will focus on installing Neovim, a plugin manager and installing a few basic plugins to get us started.

### Installing Neovim
Packages for Neovim are available for the majority of mainstream operating systems such as Linux, MacOS and Windows. I use Linux, so I'll fetch the Neovim package using my package manager.

```bash
$ sudo apt install neovim
```

### Configuring Neovim
Now that I've got Neovim installed, I can create a config directory for use with future settings and plugins.

```bash
$ mkdir ~/.config/nvim
$ touch ~/.config/nvim/init.vim
```

### Installing and a Plugin Manager
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

### Installing Neovim Plugins
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

## The Basics
### Settings
We are now going to configure some general settings for Neovim. These will be stored in a file called `settings.vim`.

```bash
$ mkdir ~/.config/nvim/general
$ touch ~/.config/nvim/general/settings.vim
```

Add the following to `settings.vim`. I've provided a little explanation to each setting that I use. These settings impact how Neovim functions, so pick and choose the settings you'd like to enable.

```vim
" set leader key
let g:mapleader = "\<Space>"

syntax enable                           " Enables syntax highlighing
set hidden                              " Required to keep multiple buffers open multiple buffers
set nowrap                              " Display long lines as just one line
set encoding=utf-8                      " The encoding displayed
set pumheight=10                        " Makes popup menu smaller
set fileencoding=utf-8                  " The encoding written to file
set ruler              			        " Show the cursor position all the time
set cmdheight=2                         " More space for displaying messages
set iskeyword+=-                      	" treat dash separated words as a word text object"
set mouse=a                             " Enable your mouse
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
set t_Co=256                            " Support 256 colors
set conceallevel=0                      " So that I can see `` in markdown files
set tabstop=2                           " Insert 2 spaces for a tab
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set smarttab                            " Makes tabbing smarter will realize you have 2 vs 4
set expandtab                           " Converts tabs to spaces
set smartindent                         " Makes indenting smart
set autoindent                          " Good auto indent
set laststatus=0                        " Always display the status line
set number                              " Line numbers
set cursorline                          " Enable highlighting of the current line
set background=dark                     " tell vim what the background color looks like
set showtabline=2                       " Always show tabs
set noshowmode                          " We don't need to see things like -- INSERT -- anymore
set nobackup                            " This is recommended by coc
set nowritebackup                       " This is recommended by coc
set updatetime=300                      " Faster completion
set timeoutlen=500                      " By default timeoutlen is 1000 ms
set formatoptions-=cro                  " Stop newline continution of comments
set clipboard=unnamedplus               " Copy paste between vim and everything else
"set autochdir                           " Your working directory will always be the same as your working directory

" You can't stop me
cmap w!! w !sudo tee %
```

We need to source the settings. Add this to `init.vim`.

```vim
source $HOME/.config/nvim/general/settings.vim
```

### Keybindings
we are going to create a directory and a file that holds our keybindings for Neovim.

```bash
$ mkdir ~/.config/nvim/keys
$ touch ~/.config/nvim/keys/mappings.vim
```

Add this to `mappings.vim`

```vim
" Use alt + hjkl to resize windows
nnoremap <M-j>    :resize -2<CR>
nnoremap <M-k>    :resize +2<CR>
nnoremap <M-h>    :vertical resize -2<CR>
nnoremap <M-l>    :vertical resize +2<CR>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

" Tabbing
vnoremap < <gv
vnoremap > >gv

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <Leader>o o<Esc>^Da
nnoremap <Leader>O O<Esc>^Da
```

We need to source the keybindings. Add this to `init.vim`.

```vim
source $HOME/.config/nvim/keys/mappings.vim
```