---
title: "Uploading my Hugo Static Assets to MinIO"
date: 2020-06-15T17:34:38+01:00
draft: false
---

So now that I've gotten my MinIO instance running and have some buckets configured to the way I like, I decided that I want to get rid of the static assets folder for this blog, and put the contents into a MinIO bucket. To do this, I'll be making use of a custom script that handles everything from bucket creation, file upload and replacing the location in all of my blog posts. Ideally I would also like the name of the bucket to represent the date of the blog post, just to match things up a little bit.

Why did I do this? Well, one day day I figured that I might actually want to share an image I have used on this blog. Instead of having to share the blog post or image location of said post, I can just share a link to my static file bucket instead. Also, keeping images and other static data stored inside a Git repository is going to make it grow pretty large over time - I want to try and avoid that. Plus, I figured it's a great exercise to do in order to improve my bash scripting skills.