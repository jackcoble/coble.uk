---
title: "Building the Ultimate Git Setup"
date: 2020-06-28T15:53:12+01:00
draft: false
---

Hello! I recently remembered that a couple of months ago, I re-deployed my Gitea instance for an open source project I am working on. All of the source code was under GitHub and in some cases I had been making use of their free private repositories for organisations, which is actually something they decided to roll out [back in April](https://github.blog/2020-04-14-github-is-now-free-for-teams/). This was a great move made by GitHub.

## A bit of background

This thought has still been with me - all of the Git repositories for my open source project are stored on GitHub. It is the only place where there is a copy of all of my repositories. In the event of a data loss on GitHub's side, I could lose some work if I didn't have the repository stored on my machine. Although this was nearly 10 years ago, I feel that the [article](https://github.blog/2010-11-15-today-s-outage/) is still relevant as to why you shouldn't put all of your eggs in one basket.

Additionally, it isn't breaking news about GitHub being censored by governments before in countries such as China, India, Russia and Turkey. Although after receiving a fair bit of backlash from this move, GitHub was eventually unblocked in these countries. My point still stands though - if it has happened before, what are the chances of it happening again? If you are interested in finding out more about the censorship of GitHub, you can take a look [here](https://en.wikipedia.org/wiki/Censorship_of_GitHub).

I'm going off topic, but just for the sake of context around censorship, the open source project I am working on promotes decentralisation and to an extent, freedom of speech through the applications we are building on top of our technology. Although the project itself violating any laws, certain countries may prohibit use of any applications built on top of our technology. One of the applications currently in the works is an encrypted messaging platform which is backed by our decentralised network of peers.

When it comes to messaging applications though, the one that comes to mind for being blocked is Telegram. It was only up until a week or so ago that Russia had lifted this restriction (it had been in place since April 2018). The application itself is not illegal, but it has been renowned for illict use. All applications of this nature are going to be used for good and unfortunately bad.

## The technology stack

Back on topic now! To build the ultimate Git setup, the technology I have used to accomplish this is Gitea and Drone. Both are an incredible piece of open source software.

### Gitea

![Gitea Image](https://s.3xpl0its.xyz/2020-06-28/Gitea_screenshot.png)

[Gitea](https://gitea.io/en-us/) is a self-hosted Git service which originally started out as a fork of [Gogs](https://gogs.io/). It is written in the Go programming language and is extremely lightweight. It even runs on a Raspberry Pi effortlessly! Naturally, because of all of this, it is my goto choice for a self-hosted Git service.

As for deploying Gitea, I use Docker compose with the instance hidden behind my Caddy reverse proxy.

```yaml
version: '3.3'
services:
    gitea:
       image: gitea/gitea:latest
       environment:
            - USER_UID=1000
            - USER_GID=1000
       restart: always
       volumes:
            - ./gitea:/data
       ports:
            - "2222:22"
            - "3000:3000"
```

Once you've got it up and running, you'll need to create an administrator account. By default, the first user on your Gitea instance will receive the administrator privileges. We now need to prepare our Gitea instance to work with Drone.

1. Create a new OAuth application. This can be done by hovering over your profile image > Settings > Applications > Manage OAuth 2 Applications. Name the application "Drone CI" or something memorable and fill in a valid redirect URI. For this, I suggest following the [documentation](https://docs.drone.io/server/provider/gitea/) and using the URL of where your future Drone instance will be located.

Once you've created the application, be sure to make a note of your "Client ID" and "Client Secret". You'll need these for setting up Drone.

### Drone

![Drone CI](https://s.3xpl0its.xyz/2020-06-28/drone.png)

[Drone CI](https://drone.io/) is a continuous integration service which is similar to the likes of Travis or Jenkins. The advantage to Drone though is that it uses containers for everything (Docker) and integrates seamlessly with my Gitea instance.

It uses the YAML markup language to configure CI instructions, which can be described as similar to Travis again.

Drone is also deployed with Docker compose, but there is a step we need to take before we can actually start.

1. Generate a shared secret. This secret will be used to communicate between our runners and our Drone instance. I recommend using the method which is also in the documentation to generate a random secret. Execute the following in your terminal.

```bash
$ openssl rand -hex 16
```

Keep a note of this secret for the time being. It can always be changed though if you have forgotten it.

2. Now we can get to filling out our Docker compose file. Let's start first with the actual Drone instance. You'll need to edit the file to match your Gitea configuration.

```yaml
version: '3.3'
services:
  drone:
    volumes:
      - "./drone/data:/data"
    environment:
      - "DRONE_GITEA_SERVER=<GITEA_INSTANCE_URL>"
      - "DRONE_GITEA_CLIENT_ID=<OAUTH2_CLIENT_ID>"
      - "DRONE_GITEA_CLIENT_SECRET=<OAUTH2_CLIENT_SECRET>"
      - "DRONE_RPC_SECRET=<SHARED_SECRET>"
      - "DRONE_SERVER_HOST=<DRONE_INSTANCE_URL>" # the url you will access drone under
      - "DRONE_SERVER_PROTO=https" # http or https
    ports:
      - "80:80"
    restart: always
    container_name: drone
    image: "drone/drone:1"
```

3. The final step to our Drone CI setup is to add in a runner. I personally use the Docker runner as it is recommended. But if you find yourself in need of something else, there are other [alternatives](https://docs.drone.io/runner/overview/) out there. Again for the configuration, modify the values where you need to.

```yaml
drone-runner-docker:
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    environment:
      - DRONE_RPC_PROTO=https # http or https
      - DRONE_RPC_HOST=<DRONE_INSTANCE_URL>
      - DRONE_RPC_SECRET=<SHARED_SECRET>
      - DRONE_RUNNER_CAPACITY=2
      - "DRONE_RUNNER_NAME=${HOSTNAME}"
    ports:
      - "3000:3000"
    restart: always
    container_name: runner
    image: "drone/drone-runner-docker:1"
```

If you piece the both sections together, your `docker-compose.yml` file should look like the following:

```yaml
version: '3.3'
services:
  drone:
    volumes:
      - "./drone/data:/data"
    environment:
      - "DRONE_GITEA_SERVER=<GITEA_INSTANCE_URL>"
      - "DRONE_GITEA_CLIENT_ID=<OAUTH2_CLIENT_ID>"
      - "DRONE_GITEA_CLIENT_SECRET=<OAUTH2_CLIENT_SECRET>"
      - "DRONE_RPC_SECRET=<SHARED_SECRET>"
      - "DRONE_SERVER_HOST=<DRONE_INSTANCE_URL>" # the url you will access drone under
      - "DRONE_SERVER_PROTO=https" # http or https
    ports:
      - "80:80"
    restart: always
    container_name: drone
    image: "drone/drone:1"
  drone-runner-docker:
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    environment:
      - DRONE_RPC_PROTO=https # http or https
      - DRONE_RPC_HOST=<DRONE_INSTANCE_URL>
      - DRONE_RPC_SECRET=<SHARED_SECRET>
      - DRONE_RUNNER_CAPACITY=2
      - "DRONE_RUNNER_NAME=${HOSTNAME}"
    ports:
      - "3000:3000"
    restart: always
    container_name: runner
    image: "drone/drone-runner-docker:1"
```

4. If you haven't done so already, launch both services with `docker-compose up -d`.

So that is all the setup done now. If you configured all of your values in the Docker compose file correctly, you should be able to visit the URL of your Drone instance and be prompted to sign in through your Gitea account if you haven't done so already.

## Mirroring my repositories to Github

When operating a Gitea instance on your own infrastructure, it is always best to maintain a copy of your repositories on another platform as a backup. You can use either GitHub or GitLab for this, but I will be using GitHub. Any provider in fact would work as long as you can push to them via SSH.

To achieve this backup method, I will be using an SSH key unique to my Gitea instance and making use of the `post-receive` Git hook in Gitea so that an action can be carried out once any new changes have been pushed.

### Generating an SSH Key
1. Lets enter our Gitea docker container.
```bash
docker-compose exec gitea bash
```

2. Navigate into the `/data` directory and make a directory inside it called `keys`.
```bash
$ cd /data
$ mkdir keys
```

3. Inside the `keys` directory, we can now generate our SSH key that we will use for our "mirroring". We will be generating the keys in this directory as it is a persistant volume. In the event of our Gitea container needing to be restarted, the SSH key won't be lost.
```
ssh-keygen -f gitea
```

4. We now need to adjust the permissions of the SSH key. If you were to try and use them now, you'd likely see an error caused due to incorrect permissions. Execute the following in the SSH key directory.
```bash
chown git:git *
```

The command above will change the ownership from our `root` user to the `git` user which Gitea makes use of. 

5. In the directory you should see a `gitea.pub` as well as the associated private key. Go ahead and upload this public key to your Git provider. For GitHub, this can be done under the Deploy Keys section. I won't go into doing that here though as there are plenty of other guides documenting the process.

6. We are all done here now, so you can go ahead and exit the Gitea container.

### Setting up the post-receive Git hook

1. On the repository of your choice, go ahead and navigate to Settings > Git Hooks and then click on the edit symbol of the `post-receive` hook. You will be presented with a text box that will allow you to enter a custom script.
```bash
#!/usr/bin/env bash

downstream_repo="git@github.com:feirm/service-layer.git" # adjust your downstream repository location
pkfile="/data/keys/gitea"

chmod 400 "$pkfile"
export GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no -i \"$pkfile\""
git push --mirror "$downstream_repo"
```

2. Click on the Update Hook button at the bottom of the page and you should be set. If you plan on using this for multiple repositories, you will need to carry out the previous step on each of the repositories.

3. Congratulations! Now whenever you make a push to a repository on your Gitea instance, it should now be mirrored to your downstream repository location! In my case it is GitHub.

## Using our Gitea + Drone CI setup
I feel that the guide wouldn't be complete without actually making use of our self-hosted setup, so what better way to do that than to actually create a basic project and make use of our CI for testing!

For my example, I will be using the Go programming language. First of all you should go ahead and create a Git repository on your Gitea instance.

![New Repository](https://s.3xpl0its.xyz/2020-06-28/Screenshot-from-2020-06-28-18-01-14.png)

If you wish to use the example I am going to create, feel free to check out the repository [here](https://git.feirm.com/jackcoble/drone-ci-example).

### Creating our Go project
The project I am going to create will be a simple HTTP server. There will be a handler attached to it that will return a message when called. I will then write a test for the handler. This is where we can make use of our CI.

1. I'm first going to create a `main.go`. This is where I'll keep the main application logic for this example.

```go
package main

import (
	"net/http"
	"log"
)

func HelloWorld(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Hello world!"))
}

func main() {
	// HTTP Handler
	http.HandleFunc("/", HelloWorld)

	// Launch our HTTP server
	log.Printf("Launching HTTP server on http://127.0.0.1:8080\n")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf(err.Error())
		return
	}
}
```

2. I'm now going to create a file called `main_test.go`. This file will contain our test for the HTTP handler.

```go
package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHelloWorld(t *testing.T) {
	// Construct a HTTP request
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Record the respose
	rr := httptest.NewRecorder()
	
	// Call the ServeHTTP method of our handler
	handler := http.HandlerFunc(HelloWorld)
	handler.ServeHTTP(rr, req)

	// Check the response code of the request
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v, want %v\n", status, http.StatusOK)
	}

	// Check the response body
	expected := "Hello world!"
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v, want %v", rr.Body.String(), expected)
	}
}
```

3. Lastly, I am now going to create the Drone CI configuration file for this project. This will reside in a file called `.drone.yml` and is specific for the Go programming language.

```yaml
kind: pipeline
name: default

steps:
  - name: test
    image: golang
    commands:
      - go test -v ./...

trigger:
  branch:
    - master
```

You should now go ahead and push these files to your Git repository. We are going to add our repository to Drone next.

### Adding our repository to Drone CI
If you visit the URL of your Drone instance, you might find that you'll have to sync your repositories. You can do this simply clicking the "Sync" button at the top right of the page. This will ask you if you want to activate Drone for any new repositories.

![Drone Sync](https://s.3xpl0its.xyz/2020-06-28/Screenshot-from-2020-06-28-18-33-27.png)

Once Drone has synced the repositories, you will now have to activate it. This can be done by clicking on the "Activate" button next to your repository.

![Activate Drone](https://s.3xpl0its.xyz/2020-06-28/Screenshot-from-2020-06-28-18-34-45.png)

You will then be taken to a settings page for your repository. Most of the time the defaults are fine, so I would personally leave them as they are. Our Drone configuration file (`.drone.yml`) contains everything we need anyway. You can just click on the "Save" button.

![Drone Settings](https://s.3xpl0its.xyz/2020-06-28/Screenshot-from-2020-06-28-18-37-35.png)

Any changes you now make will automatically trigger the Drone CI. In the configuration file I have set Drone to trigger whenever a push is made to the `master` branch.

![Drone Trigger](https://s.3xpl0its.xyz/2020-06-28/Screenshot-from-2020-06-28-18-44-24.png)

If all went well, the Drone CI pipeline should succeed as I wrote a valid test for the project. If you wish to see the results yourself, feel free to visit [here](https://drone.feirm.com/jackcoble/drone-ci-example/1).

![Drone Success](https://s.3xpl0its.xyz/2020-06-28/Screenshot-from-2020-06-28-18-47-58.png)

## Conclusion
There we have it! Our own Gitea instance and CI operating on our own hardware, with the added benefit of backups/mirrors being made to GitHub. I think it is a pretty great setup and I will continue using it for the forseeable future.

There are also plugins available for Drone CI too! I am currently using one called [drone-discord](https://github.com/appleboy/drone-discord), which will send a notification to a Discord channel via Webhook. It's a nice alternative to use instead of having to check the Drone CI status page all the time.

A big thanks to Daniel (LyteDev) for providing the post-receive hook. The original post for that can be found [here](https://lytedev.io/blog/mirroring-gitea-to-other-repository-management-services/).