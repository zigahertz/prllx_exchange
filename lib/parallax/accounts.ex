defmodule Parallax.Accounts do
  alias Parallax.Api

  # import Ecto.Query, warn: false
  # alias Parallax.Repo

  def list_users, do: Api.get_users()

  # def get_user!(id), do: list_users() |> Enum.find()

end
