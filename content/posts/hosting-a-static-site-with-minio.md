---
title: "Hosting a Static Site With MinIO"
date: 2020-06-13T19:00:51+01:00
draft: false
---

I've been wanting to have a bit more of a play with MinIO. The other day I managed to start streaming from my instance just by using a quick script I threw together, but now I want to get into the realm of hosting static websites with it.

A static website is a web page that has fixed content. You'd structure and fill in each page of a website using plain old HTML along with your CSS for styling and JavaScript for added functionality. These types of websites are the most basic out there and are the easiest to create. They are published to a web server and simply just work.

[Hugo](https://gohugo.io/) for example is a static site generator. For my blog right now I can just run the `hugo` command and it will compile my blog into a folder that can easily be deployed to the webserver/host of my choice.

If you wish to follow along, you'll need an instance of MinIO, the MinIO Client and Caddy (reverse proxy) already configured.

## Configuring the MinIO Client

As you might know, MinIO offers a web UI out of the box. Don't get me wrong, it is nice to use just for a quick overview of files, but the command-line client just makes everything easier for what we are trying to achieve.

If you haven't got the MinIO Client installed, you can visit [here](https://docs.min.io/docs/minio-client-complete-guide.html) to find the relevant binary for your operating system. Once you've got it installed, we can quickly configure a new host in a single command. The client can handle multiple storage services, but I will be focusing this "guide" (if you can call it that) just on MinIO. Run the command below with the details adjusted, and then you should be good to go.

```bash
$ mc config host add <alias> <endpoint> <access_key> <secret_key>
```

## Setting up our bucket

1. First of all, we need to create a bucket where we can dump our static files.

```bash
$ mc mb minio/static
Bucket created successfully `minio/static`.
```

2. We need to modify the permissions for our `static` bucket to make the static content accessible.

```bash
$ mc policy set download minio/static
Access permission for `minio/static` is set to `download`
```

## Upload some static content

Onto the fun part! For this demo I'm just going to upload the contents of a folder which contains a basic website. Here you can upload whatever you like.

1. Upload your static website folder to your bucket we created earlier.

```bash
$ mc cp -r demo/ minio/static
demo/style.css:                       173.79 KiB / 173.79 KiB
┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 658.10 KiB/s 0s
```

2. To check that everything transferred across, it might be worth while to list the contents of your bucket.

```bash
$ mc ls minio/static
[2020-06-13 19:40:41 BST]    447B index.html
[2020-06-13 19:40:41 BST]    155B script.js
[2020-06-13 19:40:41 BST]    450B style.css
[2020-06-13 19:42:59 BST]      0B fonts/
```

3. Now we are going to view the website you just uploaded! Visit the URL of your MinIO instance and append `/static/index.html` to the end of it. For example, your URL might turn out like the following:

```
https://m.3xpl0its.xyz/static/index.html
```

If all went well, you should see your website!

![Website Demo](https://s.3xpl0its.xyz/2020-06-13/minio-static-website.png)

## Serving the website behind Caddy

Now that you've gotten your static website deployed to your MinIO instance, it isn't really helpful having to append `/static/index.html` to your URL. To overcome this, we can serve it behind a reverse proxy. I [recently](/2020/06/migrating-from-traefik-to-caddy) switched to Caddy, so I'll be using that in this example.

If you open up your `Caddyfile`, you should be able to modify this block to match your setup and then restart Caddy.

```
demo.3xpl0its.xyz {
  rewrite * /static/{path}
  rewrite / /static/index.html
  reverse_proxy * localhost:9000
}
```

Here's a basic breakdown of what this block does:

1. Line 1 is our domain we would like to serve this web-page on.
2. Line 2 rewrites all requests to the `/static/` bucket so that the assets can be retrieved from it.
3. Line 3 rewrites any requests on `/` to retrieve the `index.html` from our `static` bucket.
4. Line 4 configures a reverse proxy to our MinIO instance.

If you adjusted the snippet correctly, you should be able to access your statically hosted website from your domain!

![Website Behind Caddy](https://s.3xpl0its.xyz/2020-06-14/minio-website-behind-caddy.png)

## That's a wrap!

So, I think that serving static content from a MinIO instance is really cool. It was definitely a learning experience for me that is for sure! I spent hours overthinking the Caddyfile configuration until I decided to take a break and rethink things through again - in the end it turned out to be quite simple...
