---
title: "Sharing files with Backblaze and Caddy"
date: 2020-09-23T16:54:12+01:00
---

I used to be an extremely heavy user of the popular open source storage server called [MinIO](https://min.io/). I used to use it for all my file sharing needs. Whilst I couldn't fault the MinIO software, I soon ran into limitations where I wanted to store potentially terrabytes of data. I'd have to increase the specifications of my VPS and rethink my backup plan if I wanted more storage. ☹️

This was where I decided it is probably better to pay a company for my needs, just because it would be cheaper and I no longer have to worry about storage limitations. After hunting around and comparing prices between a variety of services, I settled with [Backblaze B2](https://www.backblaze.com/) for my object storage needs. I was looking for something cheap, fast and reliable; Backblaze seemed to tick all of those boxes! A few months ago they even implemented an S3 compatible API, which is incredibly helpful when it comes to using certain tools such as Restic and Rclone - that is a bit outside the scope of this post though.

The plan is to keep this post short and simple. No complex explanations or anything like that - just a quick guide taking you through what you need to do in order to configure your B2 Bucket and reverse proxy it!

# Create and configure a new bucket
On my Backblaze dashboard, I am going to go ahead and create a new bucket. It is important here to make sure that the files in bucket are set to "Public", as you want people to be able to view the files you are uploading.

![New Bucket](https://s.coble.uk/2020-09-23/2020-09-23_17-13.png)

If you chose a unique bucket name and had no issues, then a new bucket shall appear on your dashboard! I decided to call mine "sharing-files-demo" for this post.

![Bucket on Dashboard](https://s.coble.uk/2020-09-23/2020-09-23_17-15.png)

Here, I would take note of the bucket endpoint as we will be needing this later on. For me, as my bucket is located in their European data centre, the endpoint would be `https://s3.eu-central-003.backblazeb2.com`. Now to make this specific to our bucket, you simply add your bucket name as a prefix to the endpoint. For example, mine would be:

```
https://sharing-files-demo.s3.eu-central-003.backblazeb2.com
```

I will be using the link above with my reverse proxy later.

## Setting the cache expiry time for a bucket
Now for this next bit, I am going out on a limb as I havent properly tested if it works, but - click on "Bucket Settings" and then enter the filed to modify the bucket information. Here I will set the "Cache-Control" header. This header is used to specify the caching policy for both client requests and server responses. There is a reason for doing this - if I have a frequent visitor who looks at the files I share, I don't want them to download the same file each time, as that would increase my monthly bill substancially due to the bandwidth being consumed.

Inside the field, you can paste the following. Of course, update the maximum amount of time you would like a file to be cached for.

```json
{
    "cache-control": "max-age=31536000"
}
```

![Bucket Information](https://s.coble.uk/2020-09-23/2020-09-23_17-24.png)

Thats it, go ahead and click "Update Bucket"! The bucket configuration is all done! 🎉 We can now move onto reverse proxying our bucket!

# Reverse proxying a bucket with Caddy
[Caddy](https://caddyserver.com/) has been my go-to reverse proxy for several months now. It handles LetsEncrypt certificates for all my domains/subdomains and automatically enforces HTTPS! In order to keep this post relatively short, I am not going to guide you how to configure Caddy from the very beginning; instead I will provide the snippet that I am using to serve all static content for this website.

Inside your Caddyfile, drop in this configuration block:

```
sharing-demo.coble.uk {
  reverse_proxy * https://sharing-files-demo.s3.eu-central-003.backblazeb2.com {
    header_up Host {http.reverse_proxy.upstream.hostport}
  }
}
```

The snippet above is telling Caddy to reverse proxy any requests that come from our subdomain through to the Backblaze B2 bucket, along with the original headers. Ensuring that the headers are sent along is important because otherwise Backblaze will not be able to fetch the specified file.

Restart your Caddy server and you should be good to go!

# Testing it all works! 🎉
To ensure that everything is working as expected, I uploaded a file to the root of my bucket and then entered the domain I configured Caddy to use, followed by the file name itself.

![It works](https://s.coble.uk/2020-09-23/2020-09-23_17-44.png)

That's all! It works! Hopefully you enjoyed this post and maybe learnt something new 