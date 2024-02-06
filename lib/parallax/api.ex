defmodule Parallax.Api do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://plx-hiring-api.fly.dev/api/"
  plug Tesla.Middleware.Headers, [{"X-Api-Key", Application.get_env(:parallax, :parallax_api_key)}]
  plug Tesla.Middleware.JSON

  @doc """
  list user fixtures
  GET /api/users
  """
  def get_users do
    {:ok, %Tesla.Env{body: %{"data" => data}}} = get("users")
    data
  end

  @doc """
  list all orders for a user
  GET /api/users/USER_ID/orders
  """
  def get_orders(user_id), do: get("users/" <> user_id <> "/orders")

  @doc """
  fetch a specific order
  GET /api/orders/ORDER_ID
  """
  def get_order(order_id), do: get("orders/" <> order_id)

  @doc """
  create quote (expires after 5 minutes)
  POST /api/quotes
  """
  def create_quote, do: post("quotes", %{})

  @doc """
  create an order tied to a quote for a given from_amount
  POST /api/orders
  """
  def create_order(user_id, quote_id, from_amount) do

  end


end
