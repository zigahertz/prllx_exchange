defmodule Parallax.Exchange.Quote do
  use GenServer
  defstruct ~w(id rate created_at from_currency to_currency status)a

  # Client API
  def start_link(via) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, via, name: via)
  end

  def show(name) do
    GenServer.call(name, :show)
  end

  # Server API
  @impl true
  def init({_, _, {_, _, state}}) do
    Process.send_after(self(), :expire, :timer.minutes(5))

    {:ok, struct!(__MODULE__, Map.put(state, :status, :active))}
  end

  @impl true
  def handle_call(:show, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:expire, state) do
    {:noreply, Map.put(state, :status, :expired)}
  end
end
