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
