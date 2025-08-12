defmodule Slink.Factory do
  @moduledoc """
  Factory as https://hexdocs.pm/ecto/test-factories.html
  """

  alias Slink.Repo

  # Factories

  def build(:user) do
    %Slink.Accounts.User{
      email: "user#{System.unique_integer()}@dev.test"
    }
  end

  # def build(:post) do
  #   %Slink.Post{title: "hello world"}
  # end

  # def build(:comment) do
  #   %Slink.Comment{body: "good post"}
  # end

  # def build(:post_with_comments) do
  #   %Slink.Post{
  #     title: "hello with comments",
  #     comments: [
  #       build(:comment, body: "first"),
  #       build(:comment, body: "second")
  #     ]
  #   }
  # end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
