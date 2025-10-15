import Config

config :ash_2385, Ash2385.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ash_2385_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :ash, policies: [show_policy_breakdowns?: true]
