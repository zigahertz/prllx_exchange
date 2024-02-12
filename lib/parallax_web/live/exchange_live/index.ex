defmodule ParallaxWeb.ExchangeLive.Index do
  use ParallaxWeb, :live_view
  alias Parallax.Exchange

  @impl true
  def mount(_, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, stream(socket, :quotes, quotes())}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {
      :noreply,
      assign(socket, page_title: "Currency Exchange", user_id: id)
    }
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, stream(socket, :quotes, quotes())}
  end

  @impl true
  def handle_event("create_quote", _, socket) do
    {:noreply, stream_insert(socket, :quotes, Exchange.create_quote(), at: 0)}
  end

  defp quotes, do: Exchange.fetch_quotes()

  def relative_time(dt) do
    time = Timex.parse!(dt, "{ISO:Extended}")
    expires_in = 5 * 60 - Timex.diff(Timex.now(), time, :second)

    cond do
      expires_in < 60 -> "#{expires_in} seconds"
      60 <= expires_in && expires_in <= 120 -> "#{div(expires_in, 60)} minute"
      true -> "#{div(expires_in, 60)} minutes"
    end
  end
end
