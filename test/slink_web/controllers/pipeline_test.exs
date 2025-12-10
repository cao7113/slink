defmodule Phoenix.Controller.PipelineTest do
  @moduledoc """
  copied from
  - https://github.com/phoenixframework/phoenix/blob/main/test/phoenix/controller/pipeline_test.exs
  """

  use ExUnit.Case, async: true
  use RouterHelper

  import Phoenix.Controller

  defmodule MyController do
    use Phoenix.Controller, formats: []
    require Logger

    @secret_actions [:secret]

    plug :prepend, :before1 when action in [:show, :create, :secret]
    plug :prepend, :before2
    plug :do_halt when action in @secret_actions

    # Delete the attribute to verify attributes in guards are expanded at call time
    Module.delete_attribute(__MODULE__, :secret_actions)

    def show(conn, _params) do
      prepend(conn, :action)
    end

    def no_fallback(_conn, _) do
      :not_a_conn
    end

    def create(conn, _) do
      prepend(conn, :action)
    end

    def secret(conn, _) do
      prepend(conn, :secret_action)
    end

    def no_match(_conn, %{"no" => "match"}) do
      raise "Shouldn't have matched"
    end

    def non_top_level_function_clause_error(conn, params) do
      send_resp(conn, :ok, trigger_func_clause_error(params))
    end

    defp trigger_func_clause_error(%{"no" => "match"}), do: :nomatch

    defp do_halt(conn, _), do: halt(conn)

    defp prepend(conn, val) do
      update_in(conn.private.stack, &[val | &1])
    end

    ## defoverridable init: 1, call: 2, action: 2
    def init(opts) do
      # opts |> dbg
      super(opts)
    end

    def call(conn, action) do
      # {conn, action} |> dbg
      super(conn, action)
    end
  end

  def init(opts), do: opts
  def call(conn, :not_a_conn), do: Plug.Conn.send_resp(conn, 200, "fallback")
  def call(_conn, :bad_fallback), do: :bad_fallback

  @moduletag :try

  setup do
    Logger.disable(self())
    :ok
  end

  test "invokes the plug stack" do
    conn =
      stack_conn()
      |> MyController.call(:show)

    assert conn.private.stack == [:action, :before2, :before1]
  end

  # test "invokes the plug stack with guards" do
  #   conn =
  #     stack_conn()
  #     |> MyController.call(:create)

  #   assert conn.private.stack == [:action, :before2, :before1]
  # end

  # test "halts prevent action from running" do
  #   conn =
  #     stack_conn()
  #     |> MyController.call(:secret)

  #   assert conn.private.stack == [:before2, :before1]
  # end

  defp stack_conn() do
    conn(:get, "/")
    |> fetch_query_params()
    |> put_private(:stack, [])
  end
end
