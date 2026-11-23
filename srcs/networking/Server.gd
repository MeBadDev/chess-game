extends Node
class_name Server

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int, code: int, reason: String)

var _tcp_server := TCPServer.new()
var _peers: Dictionary[int, WebSocketPeer] = {}
var _last_peer_id := 1

var channel_signals: Dictionary[StringName, Signal] = {}


func register_channel(channel_name: StringName) -> Signal:
	if channel_name in channel_signals:
		push_warning("Channel `%s` is already registered on Server!" % channel_name)
		return Signal()

	add_user_signal(channel_name, [
		{"name": "peer_id", "type": TYPE_INT},
		{"name": "data", "type": TYPE_DICTIONARY}
	])
	var sig := Signal(self, channel_name)
	channel_signals[channel_name] = sig
	return sig


func unregister_channel(channel_name: StringName) -> void:
	if not channel_name in channel_signals:
		push_warning("Channel `%s` is not registered on Server!" % channel_name)
		return
	remove_user_signal(channel_name)
	channel_signals.erase(channel_name)


func start(port: int) -> Error:
	var err := _tcp_server.listen(port)
	if err == OK:
		print("Server started on port %d." % port)
	else:
		push_error("Unable to start server on port %d (error %d)." % [port, err])
	return err


func send_to_peer(peer_id: int, packet: Packet) -> Error:
	var peer: WebSocketPeer = _peers.get(peer_id)
	if peer == null or peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		push_warning("Cannot send packet: peer %d is not connected." % peer_id)
		return ERR_INVALID_PARAMETER

	return peer.send(packet.serialize(), WebSocketPeer.WRITE_MODE_BINARY)


func broadcast(packet: Packet, exclude_peer_id: int = -1) -> void:
	var raw := packet.serialize()
	for peer_id in _peers:
		if peer_id == exclude_peer_id:
			continue
		var peer := _peers[peer_id]
		if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			peer.send(raw, WebSocketPeer.WRITE_MODE_BINARY)


func _handle_incoming_packet(peer_id: int, raw_packet: PackedByteArray) -> void:
	if raw_packet.is_empty():
		return

	var packet := Packet.deserialize(raw_packet)
	if packet == null:
		push_warning("Invalid packet received from peer %d." % peer_id)
		return

	var channel := StringName(packet.channel)
	if not channel in channel_signals:
		push_warning("Peer %d sent packet on unregistered channel `%s`." % [peer_id, channel])
		return

	channel_signals[channel].emit(peer_id, packet.data)


func _process(_delta: float) -> void:
	while _tcp_server.is_connection_available():
		_last_peer_id += 1
		var peer_id := _last_peer_id
		print("+ Peer %d connected." % peer_id)

		var ws := WebSocketPeer.new()
		ws.accept_stream(_tcp_server.take_connection())
		_peers[peer_id] = ws
		peer_connected.emit(peer_id)

	for peer_id in _peers.keys():
		var peer := _peers[peer_id]
		peer.poll()

		var peer_state := peer.get_ready_state()
		if peer_state == WebSocketPeer.STATE_OPEN:
			while peer.get_available_packet_count():
				_handle_incoming_packet(peer_id, peer.get_packet())
		elif peer_state == WebSocketPeer.STATE_CLOSED:
			_peers.erase(peer_id)
			var code := peer.get_close_code()
			var reason := peer.get_close_reason()
			print("- Peer %d closed with code: %d, reason: %s. Clean: %s" % [peer_id, code, reason, code != -1])
			peer_disconnected.emit(peer_id, code, reason)
