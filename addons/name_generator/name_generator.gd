extends Node

# https://nomeslegais.com/nomes-de-anjos/
# https://github.com/LukeMS/lua-namegen/blob/master/data/creatures.cfg

var species:Dictionary = {}
var directories:Dictionary = {}

# default Generator to Factory
class Generator:
	
	var male = Array()
	var female = Array()
	var family = Array()
	
	var gender_rate = 0.6 # male/famle ratio
	
	func initialize(path):
		var f = File.new()
		if f.open(path + '/female.json', File.READ)==OK:
			var data = parse_json(f.get_as_text())
			f.close()
			female = data.first
		if f.open(path + '/male.json', File.READ)==OK:
			var data = parse_json(f.get_as_text())
			f.close()
			male = data.first
		if f.open(path + '/general.json', File.READ)==OK:
			var data = parse_json(f.get_as_text())
			f.close()
			family = data.family
			if data.has('first'):
				male = data.first
	
	func generate(gender=null):
		if not gender:
			gender = 'male'
			if female.size()>0:
				if randf()>gender_rate:
					gender = 'female'
		var list = self.get(gender)
		var name = list[ randi()%list.size() ]
		name += " " + family[ randi()%family.size() ]
		
		return  name.capitalize()
	
	func _init():
		randomize()



func generate(specie=false, gender=null):
	if species.size()==0:
		return 'John Doe'
		
	if not specie:
		specie = species.keys()[0]
	
	return species[specie].generate(gender)


func update_database():
	var database_path = get_script().get_path().get_base_dir() + '/database'
	var factory_path = get_script().get_path().get_base_dir() + '/factories'
	var clear = RegEx.new()
	clear.compile("[\\W_]+")
	var dir = Directory.new()
	
	# clear actual state
	for k in species.keys():
		var s:GDScript = species[k]
		s.free()
		species.erase(k)
		directories.erase(k)
	
	if dir.open(database_path) == OK:
		dir.list_dir_begin()
		var dir_name = dir.get_next()
		while (dir_name != ""):
			if dir_name.find('.')!=0:
				var display_name = clear.sub(dir_name," ",true).capitalize()
				var class_filename = display_name.replace(" ","_").to_lower()
				var s
				if File.new().file_exists(factory_path+'/'+class_filename+'.gd'):
					var script:GDScript = ResourceLoader.load(factory_path+'/'+class_filename+'.gd','GDScript')
					s = script.new()
				else:
					s = Generator.new()
				s.initialize(database_path+'/'+dir_name)
				species[display_name] = s
				directories[display_name] = dir_name
			dir_name = dir.get_next()

func _init():
	randomize()
	update_database()

func _ready():
	pass

