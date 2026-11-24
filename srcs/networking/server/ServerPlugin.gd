@abstract extends Node
class_name ServerPlugin


var plugin_name:String
var plugin_description
var plugin_channels := []

var server: Server
@abstract func plugin_inited() -> void
