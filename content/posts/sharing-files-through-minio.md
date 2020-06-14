---
title: "Sharing Files Through MinIO"
date: 2020-06-14T11:23:51+01:00
draft: false
---

Yes, I know - another MinIO post... I promise I'll ease off on them soon. 😂

A few weeks ago, [I wrote a post](/2020/05/upload-a-static-file-server) about a static file server I had written called Upload. It is deployed as a self-contained single binary that can run on multiple operating systems. However, the files are stored and served from a folder on the host.

Now that I have been extensively using MinIO, I figured why not try and replicate my static file server. It would be great to have a public bucket that I can upload files to and share them easily. No need for fancy cloud providers like Dropbox to share my files. You could say it's *decentralised* as your files are under your own control as apposed to a cloud giant.

You might ask, why bother doing all of this when MinIO gives you the option to share files? I could make use that feature, but the URLs generated are extremely long, there is a maximum expiry period of 7 days (enforced by S3 standards) and I have to share the content manually each time I upload. All I want is a public bucket where I can dump a file, and then refer to it by its upload date and file name. No need for any long and complicated links.

Once again, I'll be using the [MinIO Client](https://docs.min.io/docs/minio-client-complete-guide.html) to configure all of this from my terminal, and to use in my helper script that I have put together.

## Creating and configuring a bucket

1. I'm just going to create a bucket through the CLI. You can call it whatever you like, but I'm going to name mine `public`.

```bash
$ mc mb minio/public
Bucket created successfully `minio/public`.
```

Next, we are going to enforce a policy to disable object listing. Right now, if you were to visit the bucket, it would return a list of all the objects you have stored inside of it. Obviously this isn't ideal as your instance could potentially be scraped by bots to download all of the content. To overcome this, we can write our own policy.

2. In your current directory, create a file named `policy.json`, and paste in this policy.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Resource": [
        "arn:aws:s3:::BUCKET/*"
      ],
      "Sid": ""
    }
  ]
}
```

> Be sure to replace 'BUCKET' with your bucket name that you configured earlier.

3. Lastly, we just need to enforce the policy on our bucket.

```bash
$ mc policy set-json policy.json minio/public
Access permission for `minio/public` is set from `policy.json`
```

Great, the new policy should be enforced. If you visit your bucket, you shouldn't be able to see the contents of it. But if you have the exact filename, you should be able to view the file as expected.

```
https://minio-instance.com/bucket/file.txt
```

![Minio Public](/img/sharing-files-through-minio/minio-public.png)

Why stop here though? At the moment, we can only access our file by referring to the bucket and then the file name. Depending on if you have nested buckets, the URL to access the file could be extremely long. This is where we can make use of Caddy!

## Serving our bucket behind Caddy

In order to cut down the length of our file URL (and to make it a bit neater), we can make use of the Caddy reverse proxy and it's rewrite functionality. You can also serve your bucket under a subdomain too, which is what I'll be covering in this example. I feel that it just helps seperate things a bit more.

By adding this snippet into your `Caddyfile` (and adjusting it as necessary), you should be good to go. For my static file bucket, I like to use the character `s` as my subdomain.

```
# Public MinIO bucket
s.3xpl0its.xyz {
  rewrite * /public/{path}
  reverse_proxy * localhost:9000
}
```

Please be sure to adjust `reverse_proxy` to the location of your MinIO instance. I have mine running on the same host as my reverse proxy, so I just use localhost. Also don't forget to update the rewrite rule - my bucket is named `public`, which is why I have my rule set to rewrite all requests to `/public/{path}` (path is dynamic - its the file you want to view. There is no need to change this part).

If you restart your Caddyfile, you should be able to view your files through your subdomain without the need of your bucket to be in the URL path.

![Minio Public Caddy](/img/sharing-files-through-minio/minio-public-caddy.png)

## Writing an upload script

To further improve our "file upload" experience, we can write a script that uploads and copies the link of a file's location to our clipboard for quick sharing. This script was written in mind for Linux users only, but if you are Windows Subsystem for Linux user, YMMV.

```bash
#!/bin/bash
# upload.sh

# Configuration variables
ALIAS=minio # The alias you set for your MinIO host using the CLI
BUCKET=public # The name of your public 'read-only' bucket
BUCKET_URL=https://s.3xpl0its.xyz # The URL of your public bucket being served behind a reverse proxy
MC_CLI=/usr/bin/mc # Location of your MinIO Client

# Get the date in YYYY-MM-DD format
DATE=$(date '+%Y-%m-%d')

if [ $# -eq 0 ]
    then
        echo "No file was supplied..."
        exit 0;
    else
        # Upload the file to the bucket
        $MC_CLI cp $1 "$ALIAS/$BUCKET/$DATE/"

        # Copy the resulting URL to our clipboard and output to terminal
        URL=$BUCKET_URL/$DATE/$1
        echo $URL | xclip -selection clipboard;
        echo $URL
fi
```

### Usage

```bash
$ ./upload.sh Screenshot_20200614_104541.png
https://s.3xpl0its.xyz/2020-06-14/Screenshot_20200614_104541.png
```

You might notice that before the file name, there is a date in the form of `YYYY-MM-DD`. The script was created so that a file is placed into a folder based on the date it was uploaded. It serves no other purpose other than to keep my files organised. It might be nice in the future for me to go through this bucket and all the different files I have uploaded. Also, it could make searching for certain files much easier if I can remember the date I uploaded them on.

Once you run this script though, the link will automatically be copied to your clipboard and outputted to the terminal for sharing. If you have chosen not to use the script, you can still upload files through the web UI and access them in the same way.

## All done!

That's all for now. If you followed through with me, then you've got a public MinIO bucket all configured to easily share files! Hope you enjoyed! :)