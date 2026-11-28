extends RefCounted
class_name Room

@export_storage var name := "Awesome Room"
@export_storage var owner : Profile
@export_storage var players :Array[Profile]
@export_storage var player_limit: int = 2

static func create(room_owner: Profile, room_name :String, room_limit: int) -> Room:
	var room := Room.new()
	room.owner = room_owner
	room.name = room_name
	room.player_limit = room_limit
	return room	

func serialize() -> Dictionary:
	return {
		"name": name,
		"owner": owner.serialize(),
		"players": Profile.serialize_array(players),
		"player_limit": 2
	}
	
static func deserialize(dict: Dictionary) -> Room:
	var room := Room.new()
	
	room.name = dict.get("name", "Awesome Room")
	room.owner = Profile.deserialize(dict.get("owner"))
	room.players = Profile.deserialize_array(dict.get("players", []))
	room.player_limit = dict.get("player_limit", 2)
	
	return room
