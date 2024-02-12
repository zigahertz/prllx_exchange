defmodule Parallax.API do
  use Tesla
  require Logger

  plug Tesla.Middleware.BaseUrl, "https://plx-hiring-api.fly.dev/api/"

  # in production, this would be modified to dynamically load an API key (from a users DB table, for example)
  plug Tesla.Middleware.Headers, [
    {"X-Api-Key", Application.get_env(:parallax, :parallax_api_key)}
  ]

  plug Tesla.Middleware.JSON, engine_opts: [keys: :atoms]
  # plug Tesla.Middleware.Logger

  @doc """
  list user fixtures
  GET /api/users
  """
  def get_users do
    get("users") |> handle_response
  end

  @doc """
  list all orders for a user
  GET /api/users/USER_ID/orders
  """
  def get_orders(user_id) do
    get("users/" <> user_id <> "/orders") |> handle_response
  end

  @doc """
  fetch a specific order
  GET /api/orders/ORDER_ID
  """
  def get_order(order_id) do
    get("orders/" <> order_id) |> handle_response
  end

  @doc """
  create quote (expires after 5 minutes)
  POST /api/quotes
  """
  def create_quote do
    post("quotes", %{}) |> handle_response
  end

  @doc """
  list all quotes
  GET /api/quotes

  """
  def get_quotes() do
    get("quotes") |> handle_response
  end

  @doc """
  create an order tied to a quote for a given from_amount
  POST /api/orders
  """
  def create_order(user_id, quote_id, from_amount) do
    post("orders", %{user_id: user_id, quote_id: quote_id, from_amount: from_amount})
    |> handle_response
  end

  def handle_response({:ok, %Tesla.Env{body: %{data: data}, status: s}}) when s in [200, 201] do
    data
  end

  def handle_response({:ok, %Tesla.Env{status: status}}) do
    Logger.error(status: status, message: "API error")
  end
end
