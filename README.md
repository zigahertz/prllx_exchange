# Parallax

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies

- Rename `dev.local.env.example` to `dev.local.env`, and copy your API key using the format shown in that file.

- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Notes (as of 3:00P, 2/12/24)

- I have sketched out an application that lets a user select a user, generate quotes, and make orders.

- To avoid excessive calls to the external API, I chose to manage state within the application using some OTP functionality versus creating a local database and using Ecto schemas, which would have been an alternative approach. Given the dynamic nature of the data from the external API, I felt that mirroring this using a local database was unnecessary and could be better modeled as follows.

I created a GenServer-based cache to contain user data. Quotes and Orders are modeled as GenServer child processes. Quote and Order uniqueness is guaranteed using a Registry (when fetching or updating quote data via the external API, we don't want to duplicate those that have already been instantiated as GenServer processes).

In interests of time, I haven't finished the section of logic that updates an order when it's complete - that part is mentioned in the comments of `Parallax.Exchange.Order`.

- It appears that executing an order for a given quote 'expires' that quote -- it cannot be used to generate another order once executed (this makes sense but wasn't mentioned in the instructions). Logic is required to update a quote's status to something like `executed` -- similar to the state expiration logic that already exists in `Parallax.Exchange.Quote.handle_info/2`. Right now, a user could attempt to create multiple orders for a single quote. They will receive a 422 from the API after generating an order from that quote.
