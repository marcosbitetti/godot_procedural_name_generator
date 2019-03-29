# Godot Procedural Name Generator Plugin

A procedural name generator for [Godot Engine 3.x](https://godotengine.org/).

### Video tutorial
[youtube]()

### Tutorial

#### Install and configure

1. Download and install plugin
1. In editor navigate to res://addons/name_generator/
1. Open file click_to_configure.tscn
1. Click on a list item to download it.
1. Click try to preview.

#### In game
Use direct from Autoload:

      var name = get_node('/root/name_generator').generate('specie_name'[,'gender'])

Use as local variable:

      var generator:Node

      func character_creation():
        var name = generator.generate('specie_name'[,'gender'])

      func _ready():
        generator = get_node('/root/name_generator')


### Functions

#### generate([ string: specie [, string: gender] ])

**"specie"** is a name (case sensitive), for example: Dwarf, Angels, Elf...
if not specie is defined, the generator catch the first in you internal list.

**"gender"**, if applicable, can be *"male"* or *"female"*.

###### Exmple:

      var generator = get_node('/root/name_generator')
      print( generator.generate('Elf') )
      print( generator.generate('Dwarf') )
      print( generator.generate('Elf', 'male') )
      print( generator.generate('Elf', 'female') )


### Database

The names are stored in this [separated repo](https://github.com/marcosbitetti/godot_procedural_name_generator_database).
