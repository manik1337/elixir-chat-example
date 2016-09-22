defmodule Chat.ServerSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      worker(Chat.Server, [Chat.Server]),
      worker(Chat.Bot, [Chat.Bot]),
      supervisor(Chat.TcpSupervisor, [Chat.TcpSupervisor]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
