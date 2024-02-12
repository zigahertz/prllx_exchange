defmodule Parallax.Exchange.Order do
  defstruct ~w(id status quote_id user_id from_amount)a

  def new(attrs \\ %{}), do: struct(__MODULE__, attrs)
end
