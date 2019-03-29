tool
extends WindowDialog

const DATABASE_URL = "https://github.com/marcosbitetti/godot_procedural_name_generator_database/tree/master/addons/name_generator/"
const DATABASE_LOCAL = "res://addons/name_generator/"
const Item:PackedScene = preload("res://addons/name_generator/ui/item.tscn")

var generator:Node
var keys = []
var devKeys = []
var files = {}
var caller:Object

func make_list():
	while $a/body/scroll/list.get_child_count()>0:
		$a/body/scroll/list.remove_child($a/body/scroll/list.get_child(0))
	
	for k in keys:
		var item = Item.instance()
		item.setup(k, generator.species.has(k), self)
		$a/body/scroll/list.add_child(item)

# change
func update_population(specie):
	caller.specie = specie
	caller.populate()


# update 
func update_database(active, name,control):
	if devKeys.find(name)>-1:
		control.call_deferred('stop',true)
		return
	#printt(active,name, DATABASE_URL + 'database/' + files[name])
	if not active:
		delete(files[name])
		if control:
			control.stop(false)
		if caller:
			caller.populate()
		return
		
	var url = DATABASE_URL + 'database/' + files[name] #+ '/'
	var http = HTTPRequest.new()
	add_child(http)
	http.use_threads = true
	http.connect("request_completed", self, "database_available",[http,control,url,files[name]])
	http.request(url, [], true, HTTPClient.METHOD_GET, "" )

# remove files
func delete(name):
	var dir = Directory.new()
	var path = DATABASE_LOCAL + 'database/'
	if dir.open( path + name )==OK:
		dir.list_dir_begin()
		var f_name = dir.get_next()
		while (f_name != ""):
			if f_name!='.' and f_name!='..':
				dir.remove(path+name+'/'+f_name)
			f_name = dir.get_next()
		path = path + name
		dir.remove(path)
	path = DATABASE_LOCAL + 'factories/' + name + '.gd'
	if dir.file_exists(path):
		dir.remove(path)

# callback of update_database to read files in first dir
func database_available(result, response_code, headers, body, http, control,url,dir_name):
	http.disconnect("request_completed", self, "database_available")
	remove_child(http)
	http.queue_free()

	var dir = Directory.new()
	var final_dir_path = DATABASE_LOCAL+'database/'+dir_name
	if dir.make_dir(final_dir_path)!=OK:
		if control:
			control.stop()
		return
	
	var tmpKeys = _extract_files(body.get_string_from_utf8(),url)
	var loading = []
	for k in tmpKeys:
		if k[0].length()>0:
			loading.append([url+'/'+k[1], final_dir_path + '/' + k[1]])
	#load_files(loading,control)
	
	var url2 = DATABASE_URL + 'factories/' + dir_name + '.gd'
	url2 = url2.replace('/tree','/raw')
	var http2 = HTTPRequest.new()
	add_child(http2)
	http2.use_threads = true
	http2.connect("request_completed", self, "factorie_available",[http2,control,url2,dir_name, loading])
	http2.request(url2, [], true, HTTPClient.METHOD_GET, "" )

func factorie_available(result, response_code, headers, body, http, control,url,dir_name, loading):
	http.disconnect("factorie_available", self, "database_available")
	remove_child(http)
	http.queue_free()
		
	if response_code==200:
		loading.append([url,DATABASE_LOCAL+'factories/'+dir_name+'.gd'])
	
	load_files(loading,control)


##
#  load a file list:
#  [ [ url, dest_pah ],... ]
##
func load_files(list, control):
	if list.size()==0:
		if control:
			control.stop(true)
		generator.update_database()
		return
	var loader = HTTPRequest.new()
	add_child(loader)
	loader.use_threads = true
	loader.filename = list[0][1]
	loader.connect("request_completed", self, "load_file_result", [loader, list, control])
	loader.request(list[0][0].replace('/tree/','/raw/'), [], true, HTTPClient.METHOD_GET, "" )

func load_file_result(result, response_code, headers, body, loader, list,control):
	loader.disconnect("request_completed",self,"load_file")
	remove_child(loader)
	loader.queue_free()
	
	var k = list.pop_front()
	var file = File.new()
	if file.open(k[1],File.WRITE)==OK:
		file.store_buffer(body)
		file.close()
	
	load_files(list,control)
#
# / ende load file list
#


# read data from base database
func read_data():
	set_process(true)
	$a/header/a/b/b/update_indicator.show()
	$a/header/a/b/b/loading_ind.show()
	$a/header/a/b/b/loading_ind.text = tr('Loading')
	var http:HTTPRequest = $http
	http.connect("request_completed", self, "data_available")
	http.request(DATABASE_URL+"database", [], true, HTTPClient.METHOD_GET, "" )
	
	#data_available(false,false,false,false)	
	#print(newBody)

# callback from read_data extract data from GitHub page
func data_available(result, response_code, headers, body):
	var http:HTTPRequest = $http
	http.disconnect("request_completed", self, "data_available")
	set_process(false)
	$a/header/a/b/b/update_indicator.hide()
	$a/header/a/b/b/loading_ind.hide()
	
	# other data
	var removeTag = RegEx.new()
	removeTag.compile("\\<[^\\>]+\\>")
	var commit_info_ready = false;
	var commit_info = '';
	var commit_date_ready = false;
	var commit_date = '';
	for l in body.get_string_from_utf8().split("\n"):
		if l.find('commit-tease')>-1 and l.find('Details')>-1:
			commit_info_ready = true
			commit_date_ready = true
		if commit_info_ready and l.find('class="message"')>-1:
			commit_info = l
			commit_info_ready = false
		if commit_date_ready and l.find('itemprop="dateModified"')>-1:
			commit_date = l
			commit_date_ready = false
			break
	$a/footer/a/a/commit.text = tr("Last update:") + " " + removeTag.sub(commit_info,'',true).strip_edges()
	$a/footer/a/a/date.text = removeTag.sub(commit_date,'',true).strip_edges()
	
	var tmpKeys = _extract_files(body.get_string_from_utf8(),DATABASE_URL+"database")
	
	# check no existin remote dirs
	var tmpDevKeys = []
	for k in generator.directories.keys():
		var ok = false
		for k2 in tmpKeys:
			if k2[0]==k:
				ok = true
				break
		if not ok:
			tmpDevKeys.append(k)
	devKeys = tmpDevKeys.duplicate()
	
	if tmpKeys.size()>0:
		keys = tmpDevKeys.duplicate()
		for k in tmpKeys:
			if k[0].length()>0:
				keys.append(k[0])
				files[k[0]]=k[1]
	
	make_list()

func _extract_files(body,path):
	path = path.substr(path.find('/name_generator/')+15,256)
	var sbody = body.split("\n")
	var files = []
	var start = false
	var getURL = RegEx.new()
	getURL.compile("(href=[\\\"\\']*[^\\\" ]+)")
	var clear = RegEx.new()
	clear.compile("[\\W_]+")
	for lin in sbody:
		if lin.find("files js-navigation-container")>-1 and not start:
			start = true
		if start:
			var mtc:RegExMatch = getURL.search(lin)
			if mtc:
				var p = mtc.get_string().find(path)
				if p>-1:
					var name = mtc.get_string().substr(p+path.length()+1,mtc.get_string().length()-p-path.length()-1)
					var display_name = clear.sub(name," ",true).capitalize()
					files.append([display_name,name])
		if lin.find("/table")>-1 and start:
			break
	return files


func _process(delta):
	$a/header/a/b/b/update_indicator.rect_rotation -= 185.0*delta

func _ready():
	generator = get_node('/root/name_generator')
	if not generator:
		generator = preload("res://addons/name_generator/name_generator.gd").new()
		generator.name = 'name_generator'
		get_node('/root').add_child(generator)
	show()
	
	keys = generator.species.keys()
	make_list()
	
	set_process(false)
	read_data()


func _on_name_generator_config_about_to_show():
	pass


func _on_name_generator_config_popup_hide():
	get_parent().remove_child(self)
	queue_free()


func _on_update_pressed():
	read_data()



func _on_link1_pressed():
	OS.shell_open("https://github.com/marcosbitetti/godot_procedural_name_generator/blob/master/README.md")

func _on_link2_pressed():
	OS.shell_open("https://youtu.be/5JOQEFrIg5A")

func _on_link3_pressed():
	OS.shell_open("https://github.com/marcosbitetti/godot_procedural_name_generator_database")

func _on_jaba1_pressed():
	OS.shell_open("http://www.wildwitchproject.com.br/p/ferramentas-tools.html")

