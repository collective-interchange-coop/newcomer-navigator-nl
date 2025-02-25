# Newcomer Navigator NL

This is the place where the development of the site
https://newcomernavigatornl.ca/ takes place.

Newcomer Navigator NL is a digital platform dedicated to helping
newcomers in Newfoundland and Labrador navigate the settlement process
with confidence and ease.

This is a project developed by:

 - [Collective Interchange](https://collectiveinterchange.com/)
 - [Better Together](https://bebettertogether.ca/)

# Architecture

This is a site mainly supported by the GEM
[community-engine-rails](https://github.com/better-together-org/community-engine-rails)
which in its core it is a Rails application.  Read its README file in
order to gain a better understanding of its Architecture.

# Develop / Collaborate

In order to try and develop this site, you can build and run a
development environment in your computer.

## Requirements

 * [Docker compose](https://docs.docker.com/engine/install/)
 * A Rails Master Key.  This would be provided by the project leader.

### Recommended folder structure

When cloning this repository, do it in a way that a folder named
`collective-interchange` is its parent folder.

Also, clone the repository of the `community-engine-rails` project in
such a way that its path, relative to this repository, is
`../../better-together/community-engine-rails`.

In other words, clone both this repository (`newcomer-navigator-nl`)
and the repository `community-engine-rails` and keep them with this
folder structure:

```
<common-root>
|
+- collective-interchange
|   \ - newcomer-navigator-nl (THIS REPO)
+- better-together
    \ - community-engine-rails
```

## Building the development environment

This instructions describe how to build this environment using Docker
Compose.  It is possible to build the environment without Docker
Compose but that is considered an advanced method not covered by this
document.

### Steps

Install the "Rails Master Key".  Simply create a file named `.env` in
the root folder of this repository, with the following content:

```shell
RAILS_MASTER_KEY=**********************
```

Substituting those asterisks (*) for the actual key (provided by the
project leader).

Then, run the following commands.

Build the application image:

```bash
docker compose build
```

Bundle the gems:

```bash
docker compose run --rm app bundle
```

Setup the database:

```bash
docker compose run --rm app rails db:setup
```

Run the RSpec tests:

```bash
docker compose run --rm app rspec
```

## Working with the development environment

### Launching the REPL console

```bash
bin/dc-console
```

### Running the app web server

```bash
bin/dc-up -d
```

Once the service is running, you can visit `http://localhost:3001` to
interact with the webapp.

### Monitor the logs

```bash
bin/dc-logs -f
```

### Check the Email Inbox

Visit `http://localhost:8026`
