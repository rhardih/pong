# Pong

[![Build Status](https://travis-ci.org/rhardih/pong.svg?branch=master)](https://travis-ci.org/rhardih/pong)

A minimal availability monitoring system with basic email alerts.

![Index](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/index.png)|![Show](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/show.png)
|:-:|:-:|
![Down alert](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/email_down.png)|![Up alert](https://media.githubusercontent.com/media/rhardih/pong/master/screenshots/email_up.png)

## System dependencies

Pong is a dockerized Rails application run via docker-compose, so both
[docker](https://www.docker.com/get-started) and
[compose](https://docs.docker.com/compose/install/) is a requirement.

## Configuration

### EMail

By default Pong uses [mailgun](https://www.mailgun.com/) as delivery method for
ActionMailer. There's no specific reason other than easy integration via
mailgun-ruby, and because they have a free plan with more than enough monthly
sends for the purpose of occasional email alerts.

Since the free plan doesn't allow ad-hoc delivery, it's necessary to the alert
receiver as an [Authorized
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
docker-compuse up -d
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
