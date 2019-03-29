tool
extends Node2D

const MAX_CREATURES = 100
const Creature:PackedScene = preload("res://addons/name_generator/ui/char.tscn")
var generator:Node

var num_creatures = 0
var config:WindowDialog
var specie:String

# Called when the node enters the scene tree for the first time.
func _ready():
	generator = get_node('/root/name_generator')
	if not generator:
		generator = preload("res://addons/name_generator/name_generator.gd").new()
		generator.name = 'name_generator'
		get_node('/root').add_child(generator)
	populate()
	
	
	config = preload("res://addons/name_generator/ui/name_generator_config.tscn").instance()
	get_tree().root.add_child(config)
	var p = ( get_viewport().get_visible_rect().size - config.rect_min_size) / 2
	p.x = 100
	config.rect_position = p
	config.show_modal(true)
	config.caller = self
	

func populate():
	while $population.get_child_count()>0:
		var c = $population.get_child(0)
		$population.remove_child(c)
		c.queue_free()
	num_creatures = 0
	_rise_creature()
	$timer.start()


func _rise_creature():
	num_creatures += 1
	if num_creatures<MAX_CREATURES:
		var c = Creature.instance()
		c.get_node('name').text = generator.generate(specie)
		$population.add_child(c)
	else:
		$timer.stop()
	
