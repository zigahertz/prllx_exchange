defmodule Parallax.Exchange.Order do
  use GenServer
  defstruct ~w(id status quote_id user_id from_amount)a

  def new(attrs \\ %{}), do: struct(__MODULE__, attrs)

  def start_link(via) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, via, name: via)
  end

  def show(name) do
    GenServer.call(name, :show)
  end

  # Server API
  @impl true
  def init({_, _, {_, _, state}}) do
    Process.send_after(self(), :check_status, :timer.seconds(5))

    {:ok, struct!(__MODULE__, state)}
  end

  @impl true
  def handle_call(:show, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:check_status, state) do
    # if state is complete, update
    # status = :complete
    # or status = :failed
    # {:noreply, Map.put(state, :status, status)}
    # otherwise, schedule this again in 5 seconds
    {:noreply, state}
  end



end
