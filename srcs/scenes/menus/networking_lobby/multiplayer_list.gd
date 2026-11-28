extends Control

@onready var user_name_input :LineEdit= $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/UsernameInput
@onready var room_name_input :LineEdit = $ColorRect/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/RoomNameInput

@onready var room_join_btn := $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/RoomCard
@onready var confirm_username_btn :Button= $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/ConfirmUsername
@onready var create_room_btn :Button= $ColorRect/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/CreateRoom

var _requested_profile :Profile
func _ready() -> void:
	await Networking.state_ready()
	Networking.client.register_channel("room")
	Networking.client.get_channel("profile").connect(_profile_channel)



func _profile_channel(data: Dictionary):
	var action :String= data.get("action")
	if action == "ack":
		if data.get("accepted", false):
			Networking.player_profile = _requested_profile
			print("server accepted :D")
		else:
			print("server rejected :(")
			print("im still called %s" % Networking.player_profile.username)

func _on_confirm_username_pressed() -> void:
	var username := user_name_input.text
	if username == Networking.player_profile.username:
		return
	_requested_profile = Networking.player_profile.duplicate(true)
	_requested_profile.username = username
	
	Networking.client.send_message(
		Packet.create("profile", _requested_profile.serialize())
	)

	


func _on_create_room_pressed() -> void:
	var room_name := room_name_input.text
	var new_room := Room.create(Networking.player_profile, room_name, 2)
	Networking.client.send_message(
		Packet.create("room", {
			"action": &"create",
			"room": new_room.serialize()
		})
	)
	
	var room_channel_msg := Networking.client.get_channel("room")
	var server_response :Dictionary = await room_channel_msg
	var accepted :bool = server_response.get("accepted", false)
	
	print(accepted)
