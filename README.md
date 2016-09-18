## Deps
  * Elixir 1.3

## Run
  * cd elixir-chat-example
  * iex -S mix

## Usage
  * server = Server.start # Start the server
  * client1 = Client.connect("Client1", server) # Create client
  * client2 = Client.connect("Client2", server) # Create client
  * send client2, {:send_message, "Hi!"} # Send message
  * send client1, :disconnect

P.S. Специально не использовал GenServer
