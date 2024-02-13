defmodule ParallaxWeb.OrdersLive.Show do
  use ParallaxWeb, :live_view
  alias Parallax.Exchange
  alias Phoenix.PubSub

  @impl true
  def mount(_, _session, socket) do
    PubSub.subscribe(Parallax.PubSub, "orders")
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => user_id, "order_id" => order_id}, _, socket) do
    {_, order} = Exchange.lookup_order(user_id, order_id)
    {_, order_quote} = Exchange.lookup_quote(order.quote_id)

    {
      :noreply,
      assign(socket, [
        page_title: "Show Order",
        order: Map.merge(order_quote, order),
        user_id: user_id
      ])
    }
  end

  @impl true
  def handle_info({:update, status}, socket) do
    {:noreply, assign(socket, :order, Map.put(socket.assigns.order, :status, status))}
  end

  def exchange_info(%{from_currency: from_curr, to_currency: to_curr, from_amount: from, rate: rate}) do
    from_curr = String.upcase(from_curr)
    to_curr = String.upcase(to_curr)
    {from, _} = Float.parse(from)
    {rate, _} = Float.parse(rate)

    [
      msg: "#{from} #{from_curr}",
      rate: "#{rate} #{to_curr} / 1 #{from_curr}",
      result: "#{from * rate} #{to_curr}"
    ]
  end
end
