---
title: "Enabling 2FA on my Servers over SSH"
date: 2020-06-17T15:59:27+01:00
draft: false
---

I recently came across something really cool - enabling two-factor authentication on a remote server when using SSH. It makes use of Google's PAM Module, which some of you may frown upon because it is developed by Google, but it is entirely open source. You can view the source [here](https://github.com/google/google-authenticator-libpam). This post is being written as I figured it'd be pretty cool to test it out and document the installation & configuration process.

> For the sake of testing purposes, I will be configuring 2FA on my local server running Debian. The process will be the same if you are using a VPS or any other Linux machine.

## What you'll need
* A Linux server of your choice.
* A TOTP authenticator app. I like [andOTP](https://github.com/andOTP/andOTP) but you might prefer Google Authenticator.

## Installing the Google PAM Module
This part shouldn't take long. It's just a couple of commands.

```bash
$ sudo apt update
$ sudo apt install libpam-google-authenticator
```

## Configuring the 2FA for your user
To get started, just run `google-authenticator` in your terminal session.

```bash
$ google-authenticator
```

You'll be prompted to answer a few questions. The first question will ask if you would like the authentication tokens to be time-based. Answer `y` to this question. After that, you should see some output in your terminal:

* QR Code - you scan this with your TOTP authenticator app.
* Secret key - if you are unable to scan the QR code, you can enter this key instead.
* Verification code - this is the first code that is specific to the QR code.
* Backup (emergency) codes - if you happen to lose your authenticator device, you can use these codes to gain access to your server.

![Google Authenticator](https://s.3xpl0its.xyz/2020-06-17/1592406959_1270x1002.png)

I'm going to try and keep this part simple as it doesn't make sense for me to show answering all of the questions. Just answer yes (`y`) to all questions except the one I'm showcasing below.

```
Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) n
```

> Please make sure that you answer no (`n`) to the question above!

## Configuring server support for 2FA

We now need to configure SSH so that 2FA is enforced on our server whenever a login attempt for our user is made.

1. We can do this by first editing the authentication file for our SSH daemon (sshd).
```bash
$ sudo vim /etc/pam.d/sshd
```

2. Using your text editor, or doing so manually, carry out a search for the line which says `@include common-auth` and **comment it out**. Normally, the two-factor authentication method we are configuring will ask for you to enter your password and then the one-time password. But because my server is configured to use SSH keys instead of a password, it makes sense to just disable entering your password twice (my SSH key password and then the user password).

3. Whilst still in the same file, go to the end of it and add this line. Once added you can save and quit the file.
```
auth required pam_google_authenticator.so
```

4. Now we need to edit the sshd configuration file so that it is aware of our new authentication method.
```bash
$ sudo vim /etc/ssh/sshd_config
```

Change the following lines:
```
ChallengeResponseAuthentication yes
UsePAM yes
```

5. After the `UsePAM` line, add the line below. Once done, save and exit the file.
```
AuthenticationMethods publickey,password publickey,keyboard-interactive
```

6. The configuration is all done! Let's restart the SSH service so that our changes can take effect.
```bash
$ sudo systemctl restart sshd
```

## Testing that it works!

> Just a word of advice before testing! After tweaking the SSH settings and trying the login for the first time, be sure to do it in another terminal session. In the event where the configuration might be incorrect, it'll allow you to easily revert your changes as you won't be locked out of your server.

If you attempt to login to your server now, you should be prompted to enter a verification code. If you load up your TOTP authenticator app, you should be able to get this code and enter it!

![SSH 2FA](https://s.3xpl0its.xyz/2020-06-17/1592410362_199x49.png)

After I've entered the code correctly, I am logged in to my server!

![NAS](https://s.3xpl0its.xyz/2020-06-17/1592410422_528x681.png)