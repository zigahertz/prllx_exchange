defmodule ParallaxWeb.ExchangeLive.Index do
  use ParallaxWeb, :live_view
  alias Parallax.Exchange

  @impl true
  def mount(%{"id" => _id}, _session, socket) do
    if connected?(socket), do: :timer.send_interval(:timer.seconds(1), self(), :tick)

    {
      :ok,
      socket
      |> stream(:quotes, [])
      |> assign(:loading, true)
      |> start_async(:hydrate_quotes, fn -> Exchange.hydrate_quotes() end)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"id" => id}) do
    socket
    |> assign(:page_title, "Quotes")
    |> assign(:user_id, id)
  end

  defp apply_action(socket, :order, %{"id" => user_id, "quote_id" => quote_id}) do
    {_, attrs} = Exchange.lookup_quote(quote_id)

    assign(socket, [page_title: "Exchange Currency", user_id: user_id, quote_attrs: attrs, exp: relative_time(attrs.created_at)])
  end

  # instead of refreshing the whole list, creating a component to do countdown timer
  @impl true
  def handle_info(:tick, socket) do
    {:noreply, stream(socket, :quotes, quotes())}
  end

  @impl true
  def handle_event("create_quote", _, socket) do
    case Exchange.create_quote() do
      %Exchange.Quote{} = q ->
        {:noreply, stream_insert(socket, :quotes, q, at: 0)}
    end
  end

  @impl true
  def handle_async(:hydrate_quotes, {:ok, quotes}, socket) do
    {
      :noreply,
      socket
      |> stream(:quotes, quotes)
      |> assign(:loading, false)
    }
  end

  defp quotes, do: Exchange.fetch_quotes()

  def relative_time(dt) do
    time = Timex.parse!(dt, "{ISO:Extended}")
    exp = 5 * 60 - Timex.diff(Timex.now(), time, :second)

    min_sec(exp)
  end

  def min_sec(sec) do
    min = div(sec, 60)

    {m, s} =
      cond do
        min == 0 -> {0, sec}
        true -> {min, sec - min * 60}
      end
    "#{m}m #{s}s"
  end
end
