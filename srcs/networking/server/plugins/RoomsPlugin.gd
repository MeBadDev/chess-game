extends ServerPlugin
class_name RoomsPlugin

var rooms :Dictionary[Profile, Room]
var profile_plugin :PlayerProfilePlugin
func _init() -> void:
	plugin_name = "Rooms Manager"
	plugin_description = "Manages rooms"
	plugin_channels = ["room"]
	plugin_id = &"rooms"
	

func plugin_inited() -> void:
	server.get_channel("room").connect(_room_channel_message_recieved)
	profile_plugin = server.plugins["profiles"]

func send_room_list_to_peer(peer: int) -> void:
	var serialized_room :Array[Dictionary]= []
	for room in rooms.values():
		serialized_room.append(room.serialize())
	
	server.send_to_peer(peer, Packet.create(
		"room",
		{
			"action": "list",
			"list": serialized_room
		}
	))

func _room_channel_message_recieved(peer: int, msg: Dictionary):
	var action :StringName = msg.get("action", null)
	
	if action == null:
		return
	
	if action == &"fetch":
		send_room_list_to_peer(peer)
		return
	
	if action == &"create":
		var requested_room :Room = Room.deserialize(msg.get("room"))
		var player_profile := profile_plugin.get_by_peer_id(peer)
		
		if not requested_room.owner.peer_id == player_profile.peer_id:
			server.send_to_peer(peer, Packet.create("room", {
				"action": "ack",
				"accepted": false
			}))
			return
		
		server.send_to_peer(peer, Packet.create("room", {
			"action": "ack",
			"accepted": true
		}))
		
