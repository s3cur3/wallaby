defmodule Wallaby.Driver.LogChecker do
  @moduledoc false
  alias Wallaby.Driver.LogStore

  def check_logs!(%{driver: driver} = session, fun) do
    return_value = fun.()

    {:ok, browser_logs} = driver.log(session, :browser)
    {:ok, performance_logs} = driver.log(session, :performance)

    session.session_url
    |> LogStore.append_logs(performance_logs ++ browser_logs)
    |> Enum.each(&driver.parse_log/1)

    return_value
  end
end
