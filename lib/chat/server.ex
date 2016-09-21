defmodule Chat.Server do
  use GenServer
  require Record

  Record.defrecordp :state, [:users]
  Record.defrecordp :user, [:name, :pid, :socket]

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  # ----
  # Client
  # ----
  def add_client(socket, name) do
    GenServer.call(__MODULE__, {:add_client, socket, name})
  end

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message, self})
  end

  # ----
  # Callbacks
  # ----
  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:ok, state(users: [])}
  end

  def handle_call({:add_client, socket, name}, {pid, _ref}, users) do
    Process.link(pid)
    message_to_broadcast = "#{name} connected\n"
    u = user(name: name, pid: pid, socket: socket)
    new_state = state(users: [u | state(users, :users)])
    broadcast(state(new_state, :users), message_to_broadcast)
    IO.puts message_to_broadcast
    {:reply, :ok, new_state}
  end

  def handle_cast({:broadcast, message, pid}, users) do
    u = find_user(state(users, :users), pid)
    message_to_broadcast = "#{user(u, :name)} -> #{message}\n"
    users_to_send = state(users: Enum.filter(state(users, :users), fn u -> user(u, :pid) != pid end))
    case users_to_send do
      {:state, [_]} ->
        broadcast(state(users_to_send, :users), message_to_broadcast)
      _ ->
        nil
    end
    IO.puts message_to_broadcast
    {:noreply, users}
  end

  def handle_info({:EXIT, from, _}, users) do
    name = user(find_user(state(users, :users), from), :name)
    message_to_broadcast = "#{name} has left\n"
    broadcast(state(users, :users), message_to_broadcast)
    new_state = state(users: Enum.filter(state(users, :users), fn u -> user(u, :pid) != from end))
    IO.puts message_to_broadcast
    {:noreply, new_state}
  end

  # ----
  # Internal functions
  # ----
  defp find_user(users, pid) do
    Enum.find(users, fn u -> user(u, :pid) == pid end)
  end

  defp broadcast(users, message) do
    Enum.map(users, fn x -> :gen_tcp.send(user(x, :socket), message) end)
  end
end
