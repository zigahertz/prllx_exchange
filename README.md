# Parallax

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies

- Rename `dev.local.env.example` to `dev.local.env`, and copy your API key using the format shown in that file.

- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Notes

- I have sketched out an application that lets a user select a user, generate quotes, and make orders.

- To avoid excessive calls to the external API, I chose to manage state within the application using some OTP functionality versus creating a local database and using Ecto schemas, which would have been an alternative approach. Given the dynamic nature of the data from the external API, I felt that mirroring this using a local database was unnecessary and could be better modeled as follows.

I created a GenServer-based cache to contain user data. Quotes and Orders are modeled as GenServer processes. Quote and Order uniqueness is guaranteed using a Registry (when fetching or updating quote data via the external API, we don't want to duplicate those that have already been instantiated as GenServer processes).

- That being said, a local database would be one way to securely manage user API tokens.
