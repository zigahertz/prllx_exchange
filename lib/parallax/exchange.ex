defmodule Parallax.Exchange do
  alias Parallax.{API, Exchange, CacheServer, QuoteRegistry, OrderRegistry, ExchangeSupervisor}
  alias Exchange.{User, Quote, Order}

  ## General Methods

  @doc """
  ensures that GenServer processes are unique i.e. quote and order data corresponding to already-existing GenServer
  processes received on subsequent API calls are ignored
  """
  def lookup_or_create_pid(attrs, server, registry) when is_map(attrs) do
    with [] <- Registry.lookup(registry, attrs.id),
        {:ok, pid} <- DynamicSupervisor.start_child(ExchangeSupervisor, {server, via_tuple(registry, attrs)}) do
      pid
    else
      [{pid, _}] -> pid
      {:error, {{:badmatch, {:error, {:already_started, pid}}}, _}} -> pid
    end
  end

  defp via_tuple(registry, attrs) do
    {:via, Registry, {registry, attrs.id, attrs}}
  end
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
  def hydrate_quotes() do
    if Registry.count(QuoteRegistry) == 0 do
      API.get_quotes() |> Enum.map(&start_quote/1)
    end
  end

  def fetch_quotes() do
    hydrate_quotes()

    DynamicSupervisor.which_children(ExchangeSupervisor)
    |> Enum.filter(fn {_, _, _, [server]} -> server == Quote end)
    |> Enum.map(fn {_, pid, _, _} -> Quote.show(pid) end)
    |> Enum.sort_by(&(&1.created_at), :desc)
  end

  def create_quote do
    API.create_quote |> start_quote
  end

  def start_quote(attrs) do
    lookup_or_create_pid(attrs, Quote, QuoteRegistry) |> Quote.show
  end

  def lookup_quote(id) do
    hydrate_quotes()
    [{pid, _ }] = Registry.lookup(QuoteRegistry, id)
    {pid, Quote.show(pid)}
  end

  ## Order logic

  def hydrate_orders(user_id) do
    if Registry.count(OrderRegistry) == 0 do
      API.get_orders(user_id) |> Enum.map(&start_order/1)
    end
  end

  def fetch_orders(user_id) do
    hydrate_orders(user_id)

    DynamicSupervisor.which_children(ExchangeSupervisor)
    |> Enum.filter(fn {_, _, _, [server]} -> server == Order end)
    |> Enum.map(fn {_, pid, _, _} -> Order.show(pid) end)
  end

  def create_order(user_id, quote_id, from_amount) do
    API.create_order(user_id, quote_id, from_amount) |> start_order
  end

  def start_order(attrs) do
    lookup_or_create_pid(attrs, Order, OrderRegistry) |> Order.show
  end

  def lookup_order(user_id, id) do
    hydrate_orders(user_id)
    [{pid, _}] = Registry.lookup(OrderRegistry, id)
    {pid, Order.show(pid)}
  end

  def ping_order(id) do
    API.get_order(id)
  end
end
