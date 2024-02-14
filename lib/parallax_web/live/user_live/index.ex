defmodule ParallaxWeb.UserLive.Index do
  use ParallaxWeb, :live_view
  alias Parallax.{Exchange}

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> stream(:users, [])
      |> start_async(:hydrate_users, fn -> Exchange.list_users end)
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Active Users")}
  end

  @impl true
  def handle_async(:hydrate_users, {:ok, users}, socket) do
    {:noreply, stream(socket, :users, users)}
  end
end
