# Hello.Umbrella

### Have you ever struggled to containerize a Phoenix umbrella application?

Me too!

That's why I created this Phoenix Docker Starter application. Please feel free to fork the code or copy the configuration you need to configure your own Phoenix docker container.

## How to use

There are 3 commands:

1. `mix deps.get`
   - We need the deps locally so Phoenix can generate a secure secret
1. `bin/build`
   - Convenience wrapper for `docker compose build` that creates the database volume for you if it doesn't already exist
1. `docker compose up`
