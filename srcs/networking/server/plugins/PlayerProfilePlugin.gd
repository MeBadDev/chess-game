extends ServerPlugin 
class_name PlayerProfilePlugin


	
var peer_profile :Dictionary[int, Profile] = {}

const BAD_WORDS := [
	"67"
]
func _init() -> void:
	plugin_name = "Player Profile"
	plugin_description = "Handles Player Profile, duh"
	plugin_channels = [&"profile"]
	plugin_id = &"profiles"

func plugin_inited():
	server.get_channel("profile").connect(on_player_profile_updated)
	server.peer_connected.connect(on_server_peer_connected)
	server.peer_disconnected.connect(on_server_peer_disconnected)

func on_server_peer_disconnected(peer_id: int, _code:int, _reason:String) -> void:
	peer_profile.erase(peer_id)

func on_server_peer_connected(peer_id: int) -> void:
	var profile := Profile.new()
	profile.username = "Player"
	profile.peer_id = peer_id
	peer_profile[peer_id] = profile
	
	server.send_to_peer(peer_id, Packet.create("profile", {
		"action": "update",
		"profile": profile.serialize()
	}))
	
func get_by_peer_id(peer_id: int) -> Profile:
	return peer_profile.get(peer_id, null)

func on_player_profile_updated(peer_id: int, new_profile: Dictionary) -> void:
	var profile :Profile= Profile.deserialize(new_profile, "Player", peer_id)
	
	var reject := func(): server.send_to_peer(peer_id, Packet.create("profile", {
		"action": "ack",
		"accepted": false
		}
	))
	
	# client can't change their own peer id
	if profile.peer_id != peer_id:
		reject.call()
		return

	for words in BAD_WORDS:
		if words in profile.username:
			reject.call()
			return
	
	server.send_to_peer(peer_id, Packet.create("profile", {
		"action": "ack",
		"accepted": true
	}))
	peer_profile[peer_id] = profile
