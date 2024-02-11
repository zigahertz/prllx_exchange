defmodule Parallax.Exchange.User do
  defstruct ~w(id name email)a

  def new(attrs \\ %{}), do: struct(__MODULE__, attrs)

  def parse(users_attrs) do
    Enum.map(users_attrs, &new/1)
  end
end
