import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  if System.get_env("PHX_SERVER") do
    config :hello_web, HelloWeb.Endpoint, server: true
  end

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :hello, Hello.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  phx_host =
    System.get_env("PHX_HOST") ||
      raise """
      environment variable PHX_HOST is missing.
      """

  phx_port = String.to_integer(System.get_env("PORT") || "4000")

  config :hello_web, HelloWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: phx_port
    ],
    url: [host: phx_host, port: phx_port],
    secret_key_base: secret_key_base

  fly_app_name = System.get_env("FLY_APP_NAME")

  topologies =
    if fly_app_name do
      # Configures libcluster to use Fly.io DNS query names
      [
        fly6pn: [
          strategy: Cluster.Strategy.DNSPoll,
          config: [
            polling_interval: 5_000,
            query: "#{fly_app_name}.internal",
            node_basename: fly_app_name
          ]
        ]
      ]
    else
      # Configures libcluster to use EPMD in Docker swarm
      [
        docker_compose: [
          strategy: Cluster.Strategy.DNSPoll,
          config: [
            node_basename: "hello_web",
            query: "hello_web",
            polling_interval: 5_000
          ]
        ]
      ]
    end

  config :libcluster,
    debug: true,
    topologies: topologies

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :hello_web, HelloWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
