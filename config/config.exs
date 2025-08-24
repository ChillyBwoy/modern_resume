# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :modern_resume,
  ecto_repos: [ModernResume.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :modern_resume, ModernResumeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ModernResumeWeb.ErrorHTML, json: ModernResumeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ModernResume.PubSub,
  live_view: [signing_salt: "0XXwzEG1"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :modern_resume, ModernResume.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  modern_resume: [
    args:
      ~w(src/app.ts --bundle --target=es2017 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --public-path=/assets/ --loader:.woff=copy --loader:.ttf=copy --loader:.eot=copy --loader:.woff2=copy),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  modern_resume: [
    args: ~w(
      --input=assets/src/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :iona,
  preprocess: [],
  processors: [pdf: "tectonic"],
  helpers: [Iona.Template.Helper]

config :ueberauth, Ueberauth,
  providers: [
    github: {
      Ueberauth.Strategy.Github,
      [
        default_scope: "user:email",
        allow_private_emails: true
      ]
    },
    google: {
      Ueberauth.Strategy.Google,
      []
    }
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
