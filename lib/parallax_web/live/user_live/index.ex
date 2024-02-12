defmodule ParallaxWeb.UserLive.Index do
  use ParallaxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, users())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Active Users")}
  end

  defp users, do: Parallax.Exchange.list_users()
end
