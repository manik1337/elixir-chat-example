defmodule Bot do

  def connect(username, server) do
    spawn(Bot, :init, [username, server])
  end

  def init(username, server) do
    send server, {:connect, self, username}
    loop(username, server)
  end

  def loop(username, server) do
    send server, {:broadcast, self, "bot_msg"}
    Process.sleep(:rand.uniform(4)*1000)
    loop(username, server)
  end
end
