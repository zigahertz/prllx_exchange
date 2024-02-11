defmodule Parallax.ExchangeServer do
  use GenServer
  alias Parallax.{API, CacheServer, Exchange}
  alias Exchange.User

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def list_users do
    GenServer.call(__MODULE__, {:list_users, []})
  end

  @impl true
  def init(opts) do
    users = API.get_users() |> User.parse()

    CacheServer.update([users: users])

    {:ok, opts}
  end

  @impl true
  def handle_info(_, {:load_users, users}) do
    IO.inspect(users, label: :users)
  end

  @impl true
  def handle_call(:list_users, _, state) do
    {:reply, CacheServer.read(:users), state}
  end

  # @quote_expiration_in_seconds 60 * 5

  # def get_quotes(threshold \\ @quote_expiration_in_seconds) do
  #   API.get_quotes()
  #   |> Enum.filter(&quote_filter(&1, threshold))
  #   # |> Enum.map()
  #   |> IO.inspect(label: :pipe)
  # end

  # defp quote_filter(%{created_at: timestamp}, threshold) do
  #   datetime_diff(timestamp) <= threshold
  # end

  # defp datetime_diff(timestamp) do
  #   timestamp
  #   |> Timex.parse!("{ISO:Extended}")
  #   |> then(&Timex.diff(Timex.now, &1, :second))
  # end
end
