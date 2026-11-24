extends Control

@onready var user_name_input :LineEdit= $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/UsernameInput
@onready var room_name_input :LineEdit = $ColorRect/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/RoomNameInput

@onready var room_join_btn := $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/RoomCard
@onready var confirm_username_btn :Button= $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/ConfirmUsername
@onready var confirm_room_name_btn :Button= $ColorRect/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/ConfirmRoomName

var _requested_profile :Profile
func _ready() -> void:
	await Networking.state_ready()
	Networking.client.register_channel("channel_list")
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

	


func _on_confirm_room_name_pressed() -> void:
	pass # Replace with function body.
