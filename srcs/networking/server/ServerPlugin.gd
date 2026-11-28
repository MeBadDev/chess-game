@abstract extends Node
class_name ServerPlugin


var plugin_name:String
var plugin_description:String
var plugin_channels :Array[StringName]= []
var plugin_id : StringName

var server: Server

@abstract func plugin_inited() -> void

func get_id() -> StringName:
	return plugin_id
