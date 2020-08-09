---
title: "Self Hosting My Emails"
date: 2020-07-13T19:35:53+01:00
draft: false
---

> As of 9th August 2020, I am no longer self-hosting my emails. Instead, I decided to retire the mail-server and add this domain to my Tutanota account. My primary issue was that any email I sent would be marked as spam by the recipient. This could be resolved by making use of an SMTP relay such as SendGrid, but that is a project for another day. I may revisit this project in the future though, so not all hope is lost!

Over the past couple of days, I have wanted to start self-hosting my emails, and for good this time. I'd previously configured an email server as part of a project I am currently working on. The functionality was nothing fancy. An email just needed to be sent to confirm the creation of a user account. However, since I was looking at setting up a mailserver for my personal use, I figure that I would to need give it a bit more care as opposed to just leaving it. After all, this could potentially be the home for the majority of my emails if it all goes well.

## Why would I want to host my own Email?
My current email provider is [Tutanota](https://tutanota.com). They've been a great provider for me since I have begun using them and they are a great company when it comes to their views on user privacy. However, a limiting factor with them (and I guess other encrypted email provders) is that I can only access my emails through their website, desktop client or mobile application. Fortunately their clients are open source and their mobile application is published on [F-Droid](https://www.f-droid.org/), so I am satisfied on that front.

I totally understand why I have to use their clients in order to access my emails. With Tutanota, everything is encrypted - at rest and if the message recipient is using a Tutanota address, the message contents are encrypted too. Unfortunately, most people I contact with via email are not using Tutanota addresses, but instead Google Mail, Hotmail, Yahoo and the like. There is absolutely no doubt that these providers are scanning every incoming email and that they are not encrypted at rest.

Before Tutanota, I was actually a heavy [ProtonMail](https://protonmail.com) user back in 2018. I paid for their Visionary plan which allowed me to have custom domains and enforced no limits on the amount of email I could send. But again, it had the same issue - I had to use ProtonMail's clients in order to access my emails, and if I wanted to access my email through IMAP or POP3, I needed to run ProtonMail bridge.

I guess what I am trying to say is that I would like to access my email wherever I can without the limitations of a custom email client, whilst maintaining control of my data and to a certain extent, my privacy. For any messages that I felt were "confidential", I always had the ability to encrypt my communications with PGP if the recipient also had a PGP key. The privacy-focused email providers are always going to do a better job of keeping my emails private, which is why I made the decision to keep my Tutanota account around for the times where I need receive critical emails from Banks and other important services.

## Mailcow
When it came to hosting an email server, I felt that [Mailcow](https://mailcow.email/) was by far the easiest to deploy. I chose to run the [Dockerised](https://github.com/mailcow/mailcow-dockerized) version as that is what my self-hosted setup evolves around.

Setting it up is quite easy. You run a couple of commands, open up a few ports and configure your domain. Before you know it, you should have a fully functional mail server. If you'd like to see a guide on how to configure Mailcow from scratch, or you need some assistance resolving some issues, then please drop me an email.

I should add that I currently run my Mailcow instance on a VPS just for the sake of reliability and the fact that I wasn't comfortable opening up ports on my home network. It doesn't help that some ISPs frown upon you opening up certain ports. ☹️

## Conclusion
My mailserver has been running for about a day now, and I've been able to send and receive messages to my shiny `3xpl0its.xyz` address. Expect to see a follow up in a months time to see if my self-hosting email journey has gone well. If you want to drop me a message to say hello, then please do so to [jack@3xpl0its.xyz](mailto:jack@3xpl0its.xyz)! 😄