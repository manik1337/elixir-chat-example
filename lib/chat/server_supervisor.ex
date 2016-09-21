defmodule Chat.ServerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Chat.Server, [Chat.Server]),
      supervisor(Chat.TcpSupervisor, [Chat.TcpSupervisor])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
