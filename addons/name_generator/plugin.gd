tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("name_generator","res://addons/name_generator/name_generator.gd")


func _exit_tree():
	remove_autoload_singleton("name_generator")
  
