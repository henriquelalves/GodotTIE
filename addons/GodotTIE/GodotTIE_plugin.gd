tool
extends EditorPlugin

func _enter_tree():
	# When this plugin node enters tree, add the custom type

	add_custom_type("TextInterfaceEngine","ReferenceFrame",preload("res://addons/GodotTIE/text_interface_engine.gd"),preload("res://addons/GodotTIE/GodotTIE_icon.png"))

func _exit_tree():
	# When the plugin node exits the tree, remove the custom type

	remove_custom_type("TextInterfaceEngine")




	
