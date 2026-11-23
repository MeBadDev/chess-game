extends Node

var server :Server
var is_server := false


const PORT = 58957
var client :Client
var websocket_url := "ws://localhost"
func _ready():
	if DisplayServer.get_name() == "headless":
		server = Server.new()
		is_server = true
		add_child(server)
		server.start(PORT)
		await server.peer_connected
		var hello_channel := server.register_channel("hello")
		hello_channel.connect(_on_server_hello)
	else:
		client = Client.new()
		add_child(client)
		client.connect_to_server(websocket_url, PORT)
		
		await client.connected
		var channel := client.register_channel("hello")
		channel.connect(_on_client_hello)
		var packet := Packet.new()
		packet.channel = &"hello"
		packet.data = {"msg": "Hi Server!"}
		client.send_message(packet)

func _on_server_hello(peer_id: int, data: Dictionary) -> void:
	print("Server got from peer %d on 'hello': %s" % [peer_id, data])
	var reply := Packet.new()
	reply.channel = &"hello"
	reply.data = {"msg": "Hi Client %d, got: %s" % [peer_id, data.get("msg", "")]}
	server.send_to_peer(peer_id, reply)

func _on_client_hello(data: Dictionary):
	print("Got message from channel Hello!")
	print(data)
