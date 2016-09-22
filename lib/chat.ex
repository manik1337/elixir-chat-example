defmodule Chat do
  use Application

  def start(_type, _params) do
    Chat.ServerSupervisor.start_link(Chat.ServerSupervisor)
  end
end
