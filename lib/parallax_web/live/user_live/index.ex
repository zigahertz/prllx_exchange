defmodule ParallaxWeb.UserLive.Index do
  use ParallaxWeb, :live_view
  # alias Task.Supervisor
  alias Parallax.{Exchange}
  # alias Parallax.{HydrationSupervisor,Exchange}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, users())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Active Users")}
  end

  @impl true
  def handle_event("hydrate", %{"id" => id}, socket) do
    # Supervisor.async(HydrationSupervisor, fn -> Exchange.hydrate_quotes() end)
    # Supervisor.async(HydrationSupervisor, fn -> Exchange.hydrate_orders(id) end)

    {:noreply, socket}
  end

  defp users, do: Exchange.list_users()
end
