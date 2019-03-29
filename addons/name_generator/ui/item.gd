tool
extends PanelContainer

var active:bool
var filepath:String

func setup(name,active,_parent):
	$box/try.connect("pressed",_parent,"update_population",[name])
	$box/specie.connect("toggled",_parent,"update_database",[name,self])
	if not active:
		$box/try.hide()
	$box/specie.text = name
	$box/specie.pressed = active

func stop(active):
	set_process(false)
	$box/loading.hide()
	if active:
		$box/try.show()
		$box/specie.pressed = true
	else:
		$box/try.hide()
		$box/specie.pressed = false

func _process(delta):
	$box/loading.rect_rotation -= 185.0*delta

func _ready():
	set_process(false)


func _on_specie_toggled(button_pressed):
	$box/try.hide()
	if button_pressed:
		$box/loading.show()
		set_process(true)
	else:
		$box/loading.hide()
