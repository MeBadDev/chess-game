extends Node
class_name Client


var socket := WebSocketPeer.new()

signal connected
signal disconnected

var is_connected := false
var can_send_packets := false

var channel_signals :Dictionary[StringName,Signal]

func register_channel(channel_name:StringName) -> Signal:
	if channel_name in channel_signals:
		print("Channel with the name `%s` is already registered!" % channel_name)
		return channel_signals[channel_name]
	
	add_user_signal(channel_name, [
		{"name": "data", "type": TYPE_DICTIONARY}
	])
	var sig := Signal(self, channel_name)
	channel_signals[channel_name] = sig
	return sig

func get_channel(channel_name: StringName) -> Signal:
	return channel_signals[channel_name]

func unregister_channel(channel_name:StringName) -> void:
	if not channel_name in channel_signals:
		print("Channel `%s` is not registered!" % channel_name)
		return
	remove_user_signal(channel_name)
	channel_signals.erase(channel_name)

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if not is_connected:
			get_tree().quit()
		socket.close()
		await disconnected
		get_tree().quit()

func connect_to_server(url: String, port: int) -> Error:
	url = url + ":%s" % port
	print("Connecting to %s" % url)
	var err := socket.connect_to_url(url)
	return err



func _handle_state() -> void:
	var state := socket.get_ready_state()

	if state == socket.STATE_OPEN:
		if is_connected:
			return
		
		is_connected = true
		can_send_packets = true
		connected.emit()
	
	
	
	if state == socket.STATE_CLOSING:
		can_send_packets = false
	
	if state == socket.STATE_CLOSED:
		if not is_connected:
			return
		
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		
		is_connected = false
		can_send_packets = false
		
		disconnected.emit()

func send_message(packet: Packet):
	if can_send_packets:
		socket.send(packet.serialize(),WebSocketPeer.WRITE_MODE_BINARY)
	else:
		push_error("Can't send packets currently!")

func handle_incoming_messages(raw_packet: PackedByteArray):
	var packet := Packet.deserialize(raw_packet)
	var channel := packet.channel
	if not channel in channel_signals:
		print("Invalid Packet, channel is not registered!")
		return
	channel_signals[channel].emit(packet.data)
func _process(_delta: float) -> void:
	socket.poll()
	_handle_state()
	
	if is_connected:
		while socket.get_available_packet_count():
			handle_incoming_messages(socket.get_packet())
