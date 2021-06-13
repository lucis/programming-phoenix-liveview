#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pento, PentoWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :pento, Pento.Repo,
  username: "postgres",
  password: "postgres",
  database: "pento_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
