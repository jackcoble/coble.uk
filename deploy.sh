#!/usr/bin/env bash

# ======================
# Hugo deployment script
# ======================

# Remove the contents of `public` directory
rm -rf $PWD/public/*

# Build the blog
/usr/bin/hugo

# Copy the blog to the folder on my server to be served through Caddy
scp -r $PWD/public/* arrow:/home/jack/Feirm-Caddy/static/blog