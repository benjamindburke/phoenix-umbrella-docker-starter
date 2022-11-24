# Hello.Umbrella

### Have you ever struggled to containerize a Phoenix umbrella application?

Me too!

That's why I created this Phoenix Docker Starter application. Please feel free to fork the code or copy the configuration you need to configure your own Phoenix docker container.

I have also created a Docker Compose branch for your convenience! Please check it out at https://github.com/benjamindburke/phoenix-umbrella-docker-starter/tree/compose-v2.

## How to use

There are 3 commands:

1. `mix deps.get`
   - We need the deps locally so Phoenix can generate a secure secret
1. `bin/build IMAGE_NAME`
   - This creates the Docker image with the `latest` tag, which we'll use as the base image in our next command
1. `bin/run IMAGE_NAME`

Well... **4 commands**.

`bin/run` will spit out a command for you to execute in your own terminal. This command requires connection info for your Ecto database. Be sure to substitute default credentials with your own.

If you don't want to start the container immediately after creation, remove the starting `docker start` and wrapping `$()` around the create command.

### Why does `bin/run` generate a command instead of executing the command?

When the script executes the command itself and the container starts, Ecto complains that it can't find the database host `host.docker.internal`, the alias to your local computer. This probably has something to do with Docker attempting to substitute the host with an IP before creating the container, but I'm not a Docker expert. So if you know of a way to fix this and let `bin/run` execute the docker start command, please fork this repo and create a pull request!