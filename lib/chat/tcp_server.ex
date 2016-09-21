defmodule Chat.TcpServer do
  use GenServer
  alias Chat.Server, as: Server

  def start_link(socket) do
    GenServer.start_link(__MODULE__, [socket])
  end

  def init([socket]) do
    spawn_link(fn -> tcp_handler(socket) end)
    {:ok, self}
  end

  defp tcp_handler(socket) do
    {:ok, sock} = :gen_tcp.accept(socket)
    spawn(fn -> client_handler(sock) end)
    tcp_handler(socket)
  end

  defp client_handler(socket) do
    :gen_tcp.send(socket, "Username: ")
    case :gen_tcp.recv(socket, 0) do
      {:ok, name} ->
        Server.add_client(socket, tcpmsg_to_string(name))
        chat(socket)
      {:error, _} ->
        :ok
    end
  end

  defp chat(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, message} ->
        Server.broadcast(tcpmsg_to_string(message))
        chat(socket)
      {:error, _} ->
        :ok
    end
  end

  defp tcpmsg_to_string(msg) do
    String.replace_trailing(to_string(msg), "\r\n", "")
  end
end
