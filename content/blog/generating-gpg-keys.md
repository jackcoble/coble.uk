---
title: "Generating GPG Keys"
date: 2020-07-11T15:21:02+01:00
draft: false
---

When it came to using [GnuPG](https://gnupg.org/) (GPG), I felt that I wasn't using it in the correct way. My setup basically evolved around a single GPG keypair which would be used for encrypting files as well as signing them.

Also not to mention that the backup method I had in place for my GPG key wasn't the greatest. I stored the revocation certificate, private key and public key all in the same directory, and on all of my machines. I also didn't have any physical backups - everything was stored digitally. 😬

Ideally I wanted a solution that would allow me to keep my key/backups offline as much as possible, whilst still be able to use GPG for my day-to-day actions.

> I should add that this post isn't intended to be a guide by any means. I felt that it would be nice to document everything that I went through to achieve this new setup. Inspiration for this post did come from an [article](https://www.paritybit.ca/blog/setting-up-gpg-keys-from-scratch) I had read previously though, so the idea technically isn't my own and I have referenced some content which is useful. Thanks to [Paritybit](https://www.paritybit.ca/) for the article! 🙂 

## Revoking my existing GPG key
Before I got started with redoing my GPG "setup", I decided it is probably best to revoke my existing key just in case I deleted my only backups by mistake. The last thing I'd want is people still using my GPG key to send me encrypted messages that I can no longer read. Fortunately, revoking a key is fairly simple as long as you have a revocation certificate present. Without it, then you are unfortunately out of luck. For me though, revoking a key went like this.

```bash
$ gpg --import gpg-revocation.asc
```

If you have access to your GPG key, but do not have a revocation certificate, then you can generate one by doing the following.

```bash
$ gpg --output gpg-revocation.asc --gen-revoke <key-id>
```

Next, I needed to send my now-revoked key to a keyserver. I had my keyservers stored inside my password manager so that I could remember where I had published it to. However, I recently discovered that there wasn't really a need for this as keyservers propogate new keys and signatures with each other every few hours, so my key technically was on all of them. Below is the command I used to achieve this.

```bash
$ gpg --keyserver pgp.mit.edu --send-keys <key-id>
```

## Generating a new Master Key
With my new setup, I have decided to make use of GPG [Subkeys](https://wiki.debian.org/Subkeys). They are like normal keys, except that they are bound to a Master Key. The link to the Debian Wiki above explains them in a better way than I currently can. Creating a new GPG key though is fairly simple. I made sure to use GnuPG 2.1.X or later as I wanted to take advantage of Elliptic Curve Cryptography (`ed25519` keys specifically). I recently regenerated my SSH keys to be `ed25519` keys, so I figured why not keep up the trend and use the same curve for my GPG key!

```bash
$ gpg --full-gen-key --expert
```

The `--expert` flag is used here to generate an ECC keypair. Once I had worked my way through selecting the curve I would like to use, I made sure to secure it with a passphrase that is unique and easy enough for me to remember. Previously I had used a randomly generated password from my password manager, but if I were to be locked out of my password manager for whatever reason, it would make life very difficult for me. Depending on your password manager and threat model, using a random password might be ideal for you. Additionally, I didn't set an expiry date for the master key as it would be a bit of a pain to go through the entire process of sharing a new public key each time.

## Generating a Revocation Certificate
Now that I've generated my new GPG key, it would be the perfect time to generate a revocation certificate. In the event that my Master Key is to be no longer trusted, I can simply revoke it so that others know not to use this key. By making use of Subkeys though, I hope to never revoke my Master Key as that will be primarily kept offline.

```bash
$ gpg --gen-revoke --armor --output=revocation-certificate.asc <user-id>
```

I used my email address as my primary identifier for my GPG key, so I would replace `<user-id>` to be `jack@3xpl0its.xyz`.

After executing that command, you should now have a revocation certificate. Great!

## Generating Subkeys
The whole idea of using a Master Key for day-to-day actions goes against its purpose. By making use of Subkeys, you can keep your master key offline for as long as possible. Additionally, they make it far easier to issue a new key and revoke existing ones in the event that they are compromised. As mentioned in Paritybit's article, I will also be generating individual subkeys for signing and encryption. This can be done executing the following command.

```bash
$ gpg --edit-key --expert jack@3xpl0its.xyz
> addkey
```

This will take you through the process of creating a subkey. The prompts are similar to when you create your master key, but just be sure to choose the `ed25519` elliptic curve on each of them.

When creating my subkeys, I decided to set an expiry of one month on each of them. By allowing my subkeys to expire, it doesn't really matter if I lose access to them as they would expire anyway. I just need to ensure that my master key is sufficiently backed up. This leads us on to the next section.

## Creating Backups
It would be catastrophic if I was to loose access to my master key and the revocation certificate for it. So I figured that to try and minimise my risk of losing access, I should keep the master key and revocation certificate offline for as long as I can and ensure that I have multiple copies available on different storage mediums (physical copies, USB flash drives and SD cards).

### Physical Backup
In order to create a physical backup, I made use of a tool called `paperkey`. It is a command line utility that allows you to export GPG keys onto paper. This process is relatively simple and only relies on a few of commands.

```bash
$ gpg --export-secret-key jack@3xpl0its.xyz > privkey.gpg
$ paperkey --secret-key privkey.gpg --output printed.txt
$ rm privkey.gpg printed.txt
```

Once you've got your printable version, you can go ahead and print it, or write it down. In my case, I ended up writing it down as I haven't got any printer ink yet. Once I do, I'll be sure to create a printed copy.

Lastly, I need to back up my revocation certificate. Fortunately this does not require `paperkey` or any utility, and is much shorter than my master key, so it took less time for me to write out. Again, when I get the chance, I'll print out a copy. That is now my physical backup medium all sorted!

### Digital Backups
Now onto the digital backup medium. I am making use of USB flash drives, SD cards and hard drives to store my master key and revocation certificate. In the event of a failure, I am most likely going to restore my master key from a digital medium due to it being much faster than entering it by hand on my keyboard. This is also the reason for having multiple digital mediums as devices are bound to become corrupt or stop working over time.

First of all, I exported my master key using the following command.

```bash
$ gpg --export-secret-keys --armor jack@3xpl0its.xyz > master.asc
```

Making use of GPG for encryption, I encrypted my exported master key as well as my revocation certificate using a random password that I generated from within my password manager.

```bash
$ gpg -c master.asc
$ gpg -c revocation-certificate.asc
$ rm master.asc revocation-certificate.asc
```

Lastly, I copied both of the encrypted files to my digital storage mediums. I am contemplating about keeping a copy on my off-site MinIO server, but I am trying to keep everything offline when I can. There should be no issue though if you decided to if the files are encrypted with a strong password, but I feel that it would defeat the point of being offline.

## Adding my Key to a Keyserver
One of the final steps to my GPG setup is to upload my public key to a keyserver. This is ideal as it allows for others on the internet to discover my public key, and it also makes it easier when it comes to restoring my master key from a physical backup. `paperkey` removes the public key parts from my private key in order to keep it short, so I need it when restoring a physical backup. I should be able to visit any keyserver and easily be able to retrieve my public key. Uploading my public key can easily be done from the command line.

```bash
$ gpg --export jack@3xpl0its.xyz | curl -T - https://keys.openpgp.org
```

Once I executed executed the above, I was prompted to verify my public key by clicking on the link found in the output. Once I did this, my public key was searchable by email address on the keyserver.

## Additional Configuration
Just a heads up, the configuration files were copied directly from Paritybit's article as they seem like sane options for GPG. If you locate your GPG configuration directory (its likely `~/.gnupg`), you can create the following files.

**gpg.conf**
```
keyserver hkps://keys.openpgp.org
keyid-format long
with-fingerprint
with-subkey-fingerprint
personal-digest-preferences SHA512
cert-digest-algo SHA512
default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
```

**gpg-agent.conf**
```
# Cache for a day
max-cache-ttl 86400
default-cache-ttl 86400
# Use curses-based pinentry program
pinentry-program /usr/bin/pinentry-curses
```

## Deleting my Master Key
Now that I've gone through the backup process for my master key, I can now remove it off of my system. I will be making use of the subkeys I have generated for day-to-day operations. By deleting my master key from GPG, it keeps it offline. I removed my master key by executing the following.

```bash
$ gpg --list-keys --with-keygrip
$ rm /media/jack/keys/gpg/private-keys-v1.d/<keygrip>.key
```

I then decrypted one of my digital backups and reimported my master key. Because my subkeys expire each month, I only need to do this once a month, and it is probably good practice to do so as it ensures my backups are still working.

```bash
$ gpg --import master.asc
```

## Conclusion
So that basically sums up how I am using GPG now. It seems to be working out quite well for me as I can keep my master key offline and just use my subkeys to carry out my tasks like normal.