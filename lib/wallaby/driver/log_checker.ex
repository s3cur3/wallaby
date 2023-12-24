defmodule Wallaby.Driver.LogChecker do
  @moduledoc false
  alias Wallaby.Driver.LogStore

  def check_logs!(%{driver: driver} = session, fun) do
    return_value = fun.()

    {:ok, browser_logs} = driver.log(session, :browser)

    performance_logs =
      case logging_level(session, :performance) do
        # Log levels: https://chromium.googlesource.com/experimental/chromium/src/+/5c38bafbf04d6196493d4bec1a851b45a1c07d12/chrome/test/chromedriver/logging.cc
        level when level in ["ALL", "DEBUG", "INFO", "WARNING", "SEVERE"] ->
          {:ok, performance_logs} = driver.log(session, :performance)
          performance_logs

        _ ->
          []
      end

    session.session_url
    |> LogStore.append_logs(performance_logs ++ browser_logs)
    |> Enum.each(&driver.parse_log/1)

    return_value
  end

  defp logging_level(%{capabilities: capabilities}, category) do
    case capabilities do
      %{loggingPrefs: %{^category => level}} when is_binary(level) -> level
      _ -> nil
    end
  end

  defp logging_level(%{parent: parent}, level), do: logging_level(parent, level)
end
