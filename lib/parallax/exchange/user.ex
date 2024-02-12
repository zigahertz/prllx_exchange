defmodule Parallax.Exchange.User do
  defstruct ~w(id name email)a

  def new(attrs \\ %{}), do: struct(__MODULE__, attrs)
end
