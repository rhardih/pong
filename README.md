# Pong

[![Build Status](https://travis-ci.org/rhardih/pong.svg?branch=master)](https://travis-ci.org/rhardih/pong)

A minimal availability monitoring system with email alerts and push notifications.

![Index](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/index.png)|![Show](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/show.png)
|:-:|:-:|
![Down alert](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/email_down.png)|![Up alert](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/email_up.png)

## System dependencies

Pong is a dockerized Rails application run via docker-compose, so both
[docker](https://www.docker.com/get-started) and
[compose](https://docs.docker.com/compose/install/) is a requirement.

## Configuration

### Notifications

#### EMail

By default Pong uses [mailgun](https://www.mailgun.com/) as delivery method for
ActionMailer. There's no specific reason other than easy integration via
mailgun-ruby, and because they have a free plan with more than enough monthly
sends for the purpose of occasional email alerts.

Since the free plan doesn't allow ad-hoc delivery, it's necessary to add the
alert receiver as an [Authorized
Recipient](https://help.mailgun.com/hc/en-us/articles/217531258-Authorized-Recipients)
in the mailgun account settings.

The application expects the following environment variables, either added the
the default compose file, or added in the
[.env](https://github.com/rhardih/pong/blob/master/.env) file.

```
MAILGUN_API_KEY
MAILGUN_DOMAIN
EMAIL_SENDER
EMAIL_RECEIVER
```

The sender is set as as default from address for all alerts, and the receiver is
the target address for all alert mailings.

For now Pong only supports a single global receiver.

#### Push (via [Telegram](telegram.org))

Pong supports push notifications, via direct chat messages over Telegram. This requires creating a dedicated [Telegram bot and corresponding API key](https://core.telegram.org/#bot-api).

Here's the necessary steps:

|&nbsp;|&nbsp;|
|:--|---|
|1. Open the application, search for *botfather* and start a chat. | ![Start chat](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/telegram0.png)|
|2. Create a new bot by issuing the `/newbot` command. | ![Create new bot](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/telegram1.png) |
|3. Go through the naming steps. Any name will do, but you'll need it shortly, so make it something you can remember. Once done, you'll be given a token to access the HTTP API.<br><br>4. Copy the API key into the the `.env` file for Pong.<br><br>5. We need the *id*, of the chat we're going to use for notifications. Pong includes a rake task, that runs the bot and replies with the id when a chat is started. Run this before the next step:<br><br>**$ docker-compose run web bin/rake telegram:run** | ![Copy api key](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/telegram2.png)|
|6. Next open a chat with the newly created bot. Here you need the name you chose in step 3. | ![Open bot chat](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/telegram3.png)|
|7. Upon joining the chat with the bot, you will be given the chat id we need.<br><br>8. Copy the chat id into the `.env` file, as you did with the api key and you're all set. Now Pong will send you notifications via this chat. | ![Get chat id](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/telegram4.png)|

### Docker image

For easier deployment, Pong is packaged as a fully self-contained docker image
in production mode. A default image build is available on the
[dockerhub](https://hub.docker.com/r/rhardih/pong), but a custom or self built
image can be used by setting the corresponding environment variable:

```
PROD_IMAGE=rhardih/pong:latest
```

## Run

Bring up all compose services with:

```bash
docker-compose up -d
```

### Database creation & initialization

```bash
docker-compose run web bin/rake db:create
docker-compose run web bin/rake db:migrate
```

### How to run the test suite

This app uses the default minitest framework.

In development mode, a test compose service with a spring preloaded environment
is added for running tests faster.

To run all tests:

```bash
docker-compose exec test bin/rake test
```

To run specific test:

```bash
docker-compose exec test bin/rake test TEST=test/jobs/request_job_test.rb
```

## Services

The default application stack, as can also be seen in
[docker-compose.yml](https://github.com/rhardih/pong/blob/master/docker-compose.yml),
consists of the following components:

* Database server running [PostgreSQL](https://www.postgresql.org/).
* Key value store running [redis](https://redis.io/).
* A worker instance, running a [resque](https://github.com/resque/resque) worker.
* A static job scheduler running
  [resque-scheduler](https://github.com/resque/resque-scheduler).
* Default Puma web server.

### Development

Aside from the services listed above, these are added for local development:

* A test instance, with a preloaded spring environment.
* A [MailCatcher](https://mailcatcher.me/) instance.

## Deployment instructions

Assuming the production host is reachable and running docker, setting the
following should be enough to let compose do deploys:

```
DOCKER_HOST=tcp://<url-or-ip-of-remote-host>:2376
DOCKER_TLS_VERIFY=1
```

Then adding reference to the production config:

```bash
docker-compose -f docker-compose.yml -f production.yml up -d
```

Remember to create and initialize the database as well.

## System design notes

### Check

In order to somewhat alleviate spurious alert triggerings, when a request for a check fails, it is put into an intermediate state of *limbo*, before being definitively marked as being *down*. When in *limbo*, a check is performed every minute until it either comes back *up*, or is finally marked as *down* after a set number of retries each failed as well. Below is transition diagram illustrating how the status of a Check changes:

![Check status](https://media.githubusercontent.com/media/rhardih/pong/master/diagrams/check-status-transition.png)

One thing to note, is that when a check is either in *limbo* or is *down*, its
interval is disregarded, and a request is triggered every time the queue job is
running, which is roughly once every minute.
