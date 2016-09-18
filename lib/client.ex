defmodule Client do

  def connect(username, server) do
    spawn(Client, :init, [username, server])
  end

  def init(username, server) do
    send server, {:connect, self, username}
    loop(username, server)
  end

  def loop(username, server) do
    receive do
      {:info, message} ->
        IO.puts(~s{<#{username}'s> - #{message}})
        loop(username, server)
      {:message, from, message} ->
        IO.puts(~s{<#{username}'s> - #{from}: #{message}})
        loop(username, server)
      {:send_message, message} ->
        send server, {:broadcast, self, message}
        loop(username, server)
      {:error, message} ->
        IO.puts(message)
        exit(0)
      :disconnect ->
        exit(0)
    end
  end
end
