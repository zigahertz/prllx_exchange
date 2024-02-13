defmodule Parallax.Exchange.Order do
  use GenServer
  alias Parallax.Exchange
  alias Phoenix.PubSub

  defstruct ~w(id status quote_id user_id from_amount)a

  def new(attrs \\ %{}), do: struct(__MODULE__, attrs)

  def start_link(via) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, via, name: via)
  end

  def show(name) do
    GenServer.call(name, :show)
  end

  def update(name, data) when is_list(data) do
    GenServer.cast(name, {:update, data})
  end

  # Server API
  @impl true
  def init({_, _, {_, _, state}}) do
    check_status(state)
    {:ok, struct!(__MODULE__, state)}
  end

  @impl true
  def handle_call(:show, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:update, data}, state) do
    {:noreply, struct!(state, data)}
  end

  @impl true
  def handle_info(:check_status, state) do
    check_status(Exchange.ping_order(state.id))
    {:noreply, state}
  end

  defp check_status(%{status: "pending"}) do
    Process.send_after(self(), :check_status, :timer.seconds(5))
  end

  defp check_status(%{status: status}) do
    PubSub.broadcast(Parallax.PubSub, "orders", {:update, status})
    update(self(), [status: status])
  end

end
