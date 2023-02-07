# Hello.Umbrella

### Have you ever struggled to containerize a Phoenix umbrella application?

Me too!

That's why I created this Phoenix Docker Starter application. Please feel free to fork the code or copy the configuration you need to configure your own Phoenix Docker swarm.

## How to use HelloWeb

First, add your own application secrets to the files in [docker-local/db.env](./docker-local/db.env) and [docker-local/dev.env](./docker-local/dev.env).

Use these three commands to build the `hello_web` Docker service locally:

1. `mix deps.get`
   - We need the deps locally so Phoenix can generate a secure secret: `mix phx.gen.secret`
   - You should change your SECRET_KEY_BASE in [docker-compose.yml](./docker-compose.yml) but it isn't required for local development.
1. `docker compose build`
1. `docker compose up`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
