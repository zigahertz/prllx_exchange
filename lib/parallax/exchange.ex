defmodule Parallax.Exchange do
  alias Parallax.{API, Exchange, CacheServer}
  alias Exchange.{User, Quote}

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
    case Registry.count(QuoteRegistry) do
      0 ->
        API.get_quotes()
        |> Enum.filter(&quote_filter(&1, threshold))
        |> Enum.map(&start_quote/1)

      _ ->
        DynamicSupervisor.which_children(QuoteSupervisor)
        |> Enum.map(fn {_, pid, _, _} -> Quote.show(pid) end)
    end
    |> Enum.sort_by(&(&1.created_at), :desc)
  end

  defp via_tuple(attrs) do
    {:via, Registry, {QuoteRegistry, attrs.id, attrs}}
  end

  def create_quote do
    API.create_quote |> start_quote
  end

  def start_quote(attrs) do
    lookup_or_create_quote_pid(attrs) |> Quote.show
  end

  @doc """
  ensures that quotes are unique i.e. quote data corresponding to an already-existing GenServer
  received on subsequent API calls are ignored
  """
  def lookup_or_create_quote_pid(attrs) when is_map(attrs) do
    with [] <- Registry.lookup(QuoteRegistry, attrs.id),
        {:ok, pid} <- DynamicSupervisor.start_child(QuoteSupervisor, {Quote, via_tuple(attrs)}) do
      pid
    else
      [{pid, _}] -> pid
      {:error, {{:badmatch, {:error, {:already_started, pid}}}, _}} -> pid
    end
  end

  defp quote_filter(%{created_at: timestamp}, threshold) do
    datetime_diff(timestamp) <= threshold
  end

  defp datetime_diff(timestamp) do
    timestamp
    |> Timex.parse!("{ISO:Extended}")
    |> then(&Timex.diff(Timex.now(), &1, :second))
  end
end
