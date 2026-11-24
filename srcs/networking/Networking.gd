extends Node

var server :Server
var is_server := false


const PORT = 58957
var client :Client
var websocket_url := "ws://localhost"

var player_profile := Profile.new()

signal _client_initialized
func state_ready():
	if not is_node_ready():
		await ready
	if client == null:
		await _client_initialized
	if not client.is_connected:
		await client.connected
	return

func _start_server():
	server = Server.new()
	is_server = true
	add_child(server)
	server.start(PORT)
	
	var plugins := [PlayerProfilePlugin.new()]
	for plugin in plugins:
		server.register_plugin(plugin)


func _ready():
	if DisplayServer.get_name() == "headless":
		_start_server()
	else:
		client = Client.new()
		add_child(client)
		client.connect_to_server(websocket_url, PORT)

		_client_initialized.emit()
		Networking.client.register_channel("profile").connect(_profile_channel)
		
		await client.connected



func _profile_channel(data: Dictionary):
	var action :String= data.get("action")
	
	if action == "update":
		player_profile = Profile.deserialize(data.get("profile"))
