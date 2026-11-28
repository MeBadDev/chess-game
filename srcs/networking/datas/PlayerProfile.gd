extends Resource
class_name Profile

@export_storage var username := "Player"
@export_storage var peer_id := -1
func serialize() -> Dictionary:
	return {
		"username": username,
		"peer_id": peer_id
	}

static func deserialize(dict: Dictionary, default_username := "Player", default_peer_id := -1) -> Profile:
	var profile := Profile.new()
	profile.username = dict.get("username", default_username)
	profile.peer_id = dict.get("peer_id", default_peer_id)
	return profile

static func serialize_array(array: Array[Profile]) -> Array[Dictionary]:
	var arr :Array[Dictionary] = []
	for players in array:
		arr.append(players.serialize())
	
	return arr

static func deserialize_array(array: Array[Dictionary]) -> Array[Profile]:
	var arr :Array[Profile] = []
	for players in array:
		arr.append(deserialize(players))
	
	return arr
