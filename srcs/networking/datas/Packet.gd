extends RefCounted
class_name Packet


var channel :StringName
var data :Dictionary


func serialize() -> PackedByteArray:
	return var_to_bytes({
		"channel": channel,
		"data": data
	})

static func deserialize(raw_data: PackedByteArray) -> Packet:
	var data_dict :Dictionary = bytes_to_var(raw_data)

	if not data_dict.get("channel") is StringName:
		print("Invalid Packet! Invalid Channel")
		return
	
	if not data_dict.get("data") is Dictionary:
		print("Invalid Packet! Invalid Data")
		return
	var new_packet := Packet.new()
	new_packet.channel = data_dict.get("channel")
	new_packet.data = data_dict.get("data")

	return new_packet

static func create(channel_name: StringName, data: Dictionary) -> Packet:
	var packet := Packet.new()
	packet.channel = channel_name
	packet.data = data
	return packet
