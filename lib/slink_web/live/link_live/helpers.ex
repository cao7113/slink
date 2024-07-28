defmodule SlinkWeb.LinkLive.Helpers do
  @moduledoc """
  LinkLive Helpers
  """

  def allow_do?(op, _link, nil) when op in [:edit, :delete], do: false

  def allow_do?(:edit, link, current_user) do
    link.user_id == current_user.id
  end

  def allow_do?(:delete, link, current_user) do
    link.user_id == current_user.id
  end

  def allow_do?(_, _, _), do: false
end
