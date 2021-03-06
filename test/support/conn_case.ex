defmodule Hexpm.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Hexpm.{Fake, Repo}
      alias Hexpm.Web.Router.Helpers, as: Routes

      import Ecto
      import Ecto.Query, only: [from: 2]
      import Hexpm.{Case, Factory, TestHelpers}
      import unquote(__MODULE__)

      # The default endpoint for testing
      @endpoint Hexpm.Web.Endpoint
    end
  end

  setup tags do
    opts = tags |> Map.take([:isolation]) |> Enum.to_list()
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Hexpm.Repo, opts)
    Hexpm.Case.reset_store()
    Bamboo.SentEmail.reset()
    :ok
  end

  def test_login(conn, user) do
    Plug.Test.init_test_session(conn, %{"user_id" => user.id})
  end

  def last_session() do
    import Ecto.Query

    from(s in Hexpm.Accounts.Session, order_by: [desc: s.id], limit: 1)
    |> Hexpm.Repo.one()
  end

  def json_post(conn, path, params) do
    conn
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> Phoenix.ConnTest.dispatch(Hexpm.Web.Endpoint, :post, path, Jason.encode!(params))
  end
end
