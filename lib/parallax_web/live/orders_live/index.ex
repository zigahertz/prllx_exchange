defmodule ParallaxWeb.OrdersLive.Index do
  use ParallaxWeb, :live_view
  alias Parallax.Exchange

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {
      :noreply,
      socket
      |> assign(:user_id, id)
      |> stream(:orders, orders(id))
    }
  end

  defp orders(id), do: Exchange.fetch_orders(id)
end
