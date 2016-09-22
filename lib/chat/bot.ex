defmodule Chat.Bot do
  use GenServer
  alias Chat.Server, as: Server

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    spawn_link(fn -> setup_bot end)
    {:ok, self}
  end

  defp setup_bot(bot_name \\ "Bot") do
    Server.add_client(nil, bot_name)
    bot_loop
  end

  defp bot_loop do
    Server.broadcast("Hello! I am bot!")
    Process.sleep(:rand.uniform(4)*1000)
    bot_loop
  end

end
