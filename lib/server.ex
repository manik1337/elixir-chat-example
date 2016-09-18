defmodule Server do
  alias Bot

  def start do
    spawn(Server, :init, [])
  end

  def init do
    Process.flag(:trap_exit, true)
    bot_pid = spawn_link(Bot, :connect,["botname", self])
    loop([{bot_pid, "botname"}])
  end

  def loop(users) do
    receive do
      {:connect, pid, username} ->
        Process.link(pid)
        broadcast({:info, username <> " joined."}, users)
        loop([{pid, username} | users])
      {:broadcast, pid, message} ->
        broadcast({:message, get_username(pid, users), message}, users)
        loop(users)
      {:EXIT, pid, _} ->
        broadcast({:info, get_username(pid, users) <> " left the chat."}, users)
        loop(users |> Enum.filter(fn {receiver, _} -> receiver != pid end))
      {:error, _pid, message} ->
        IO.puts message
        loop(users)
      {_} ->
        loop(users)
    end
  end

  defp broadcast(message, clients) do
    Enum.each clients, fn {pid, _} -> send pid, message end
  end

  defp get_username(pid, [{user_pid, username} | _]) when pid == user_pid, do: username
  defp get_username(pid, [_ | t]), do: get_username(pid, t)
end
