defmodule ParallaxWeb.UserLive.Index do
  use ParallaxWeb, :live_view
  alias Parallax.CacheServer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Active Users")
    |> assign(:user_id, nil)
  end

  defp users, do: CacheServer.read(:users)
end
