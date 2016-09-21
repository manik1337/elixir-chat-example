defmodule Chat.TcpSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    port = Application.get_env(:chat, :port)
    {:ok, socket} = :gen_tcp.listen(port, [{:active, false}])

    children = [
      worker(Chat.TcpServer, [socket], name: Chat.TcpServer, restart: :temporary)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
