defmodule Parallax.Exchange.Quote do
  use GenServer
  defstruct ~w(id rate created_at from_currency to_currency status)a

  @expiration_seconds 5 * 60

  # Client API
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
    status = is_expired?(state) |> handle_expired

    {:ok, struct!(__MODULE__, Map.put(state, :status, status))}
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
  def handle_info(:expire, state) do
    {:noreply, Map.put(state, :status, :expired)}
  end

  def handle_expired(true), do: :expired
  def handle_expired(false) do
    Process.send_after(self(), :expire, :timer.minutes(5))
    :active
  end

  def is_expired?(%{created_at: timestamp}, threshold_in_seconds \\ @expiration_seconds) do
    datetime_diff(timestamp) > threshold_in_seconds
  end

  defp datetime_diff(timestamp) do
    timestamp
    |> Timex.parse!("{ISO:Extended}")
    |> then(&Timex.diff(Timex.now(), &1, :second))
  end

end
