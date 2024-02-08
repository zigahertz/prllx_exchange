defmodule ParallaxWeb.UserLive.Index do
  use ParallaxWeb, :live_view

  alias Parallax.Accounts
  alias ParallaxWeb.UserJSON, as: J
  # alias Parallax.Accounts.User

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
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({ParallaxWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  defp users, do: Enum.map(Accounts.list_users(), &J.data/1)
end

defmodule ParallaxWeb.UserJSON do
  alias Parallax.Accounts.User

  # def show(%{user: user}) do
  #   %{data: data(user)}
  # end

  def data(%{"email" => email, "id" => id, "name" => name}) do
    %User{
      id: id,
      name: name,
      email: email
    }
  end
end
