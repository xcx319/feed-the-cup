

tool
extends EditorPlugin

var import_plugin_tilesheet = null
var import_plugin_spritesheet = null

func get_name():
	return "TexturePacker Importer"

func _enter_tree():
	import_plugin_tilesheet = preload("texturepacker_import_tileset.gd").new()
	add_import_plugin(import_plugin_tilesheet)
	import_plugin_spritesheet = preload("texturepacker_import_spritesheet.gd").new()
	add_import_plugin(import_plugin_spritesheet)

func _exit_tree():
	remove_import_plugin(import_plugin_spritesheet)
	import_plugin_spritesheet = null
	remove_import_plugin(import_plugin_tilesheet)
	import_plugin_tilesheet = null
