defmodule Parallax.CacheServer do
  use GenServer
  require Logger

  defstruct [:users]

  ## Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def update(data) when is_list(data) do
    GenServer.cast(__MODULE__, {:update, data})
  end

  def read(lookup) do
    GenServer.call(__MODULE__, {:read, lookup})
  end

  ## Server API
  @impl true
  def init(_opts) do
    {:ok, struct!(__MODULE__, users: [])}
  end

  @impl true
  def handle_call({:read, [schema, id]}, _, state) do
    {:reply, Keyword.get(state, schema) |> Map.get(id), state}
  end

  @impl true
  def handle_call({:read, schema}, _, state) do
    {:reply, Map.get(state, schema), state}
  end

  @impl true
  def handle_cast({:update, data}, state) do
    {:noreply, struct!(state, data)}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.warning(msg)
    {:noreply, state}
  end

end
