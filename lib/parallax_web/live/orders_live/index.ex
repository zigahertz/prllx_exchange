defmodule ParallaxWeb.OrdersLive.Index do
  use ParallaxWeb, :live_view
  alias Parallax.Exchange

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {
      :ok,
      socket
      |> assign(:user_id, id)
      |> stream(:orders, [])
      |> assign(:loading, true)
      |> start_async(:hydrate_orders, fn  -> Exchange.hydrate_orders(id) end)
    }
  end

  @impl true
  def handle_async(:hydrate_orders, {:ok, orders}, socket) do
    {
      :noreply,
      socket
      |> assign(:loading, false)
      |> stream(:orders, orders)
    }
  end
end
