defmodule Parallax.Exchange do
  alias Parallax.{API, Exchange, CacheServer}
  alias Exchange.{User, Quote, Order}

  ## User logic

  def list_users do
    with [] <- CacheServer.read(:users),
         users <- API.get_users() |> parse_users,
         :ok <- CacheServer.update(users: users) do
      CacheServer.read(:users)
    else
      users -> users
    end
  end

  defp parse_users(attrs) do
    Enum.map(attrs, &User.new/1)
  end

  ## Quote logic

  @quote_expiration_in_seconds 5 * 60

  def fetch_quotes(threshold \\ @quote_expiration_in_seconds) do
    case Registry.count(ParallaxRegistry) do
      0 ->
        API.get_quotes()
        |> Enum.filter(&quote_filter(&1, threshold))
        |> Enum.map(&start_quote/1)

      _ ->
        DynamicSupervisor.which_children(ExchangeSupervisor)
        |> Enum.filter(fn {_, _, _, [server]} -> server == Quote end)
        |> Enum.map(fn {_, pid, _, _} -> Quote.show(pid) end)
    end
    |> Enum.sort_by(&(&1.created_at), :desc)
  end

  def create_quote do
    API.create_quote |> start_quote
  end

  def start_quote(attrs) do
    lookup_or_create_pid(attrs, Quote) |> Quote.show
  end

  defp quote_filter(%{created_at: timestamp}, threshold) do
    datetime_diff(timestamp) <= threshold
  end

  defp datetime_diff(timestamp) do
    timestamp
    |> Timex.parse!("{ISO:Extended}")
    |> then(&Timex.diff(Timex.now(), &1, :second))
  end

  ## Order logic

  def create_order(user_id, quote_id, from_amount) do
    API.create_order(user_id, quote_id, from_amount) |> start_order
  end

  def start_order(attrs) do
    lookup_or_create_pid(attrs, Order) |> Order.show
  end

  def fetch_orders(user_id) do
    case Registry.count(ParallaxRegistry) do
      0 ->
        API.get_orders(user_id) |> Enum.map(&start_order/1)

      _ ->
        DynamicSupervisor.which_children(ExchangeSupervisor)
        |> Enum.filter(fn {_, _, _, [server]} -> server == Order end)
        |> Enum.map(fn {_, pid, _, _} -> Order.show(pid) end)
    end
  end


  @doc """
  ensures that GenServer processes are unique i.e. quote and order data corresponding to already-existing GenServer
  processes received on subsequent API calls are ignored
  """
  def lookup_or_create_pid(attrs, server) when is_map(attrs) do
    with [] <- Registry.lookup(ParallaxRegistry, attrs.id),
        {:ok, pid} <- DynamicSupervisor.start_child(ExchangeSupervisor, {server, via_tuple(attrs)}) do
      pid
    else
      [{pid, _}] -> pid
      {:error, {{:badmatch, {:error, {:already_started, pid}}}, _}} -> pid
    end
  end

  defp via_tuple(attrs) do
    {:via, Registry, {ParallaxRegistry, attrs.id, attrs}}
  end

end
