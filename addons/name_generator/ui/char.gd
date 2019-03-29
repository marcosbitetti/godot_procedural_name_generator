tool
extends Sprite

const SPD = 12.0
const RANDOM_TIME = 4.0
const FRAME_TIME = 0.3

var ani = 0
var dir = Vector2(0,1)
var time = 0.0
var delay = 0.0

func _process(delta):
	time += delta
	delay -= delta
	var f = frame
	
	if delay<0.0:
		delay = randf()*RANDOM_TIME
		ani = 4 * (randi()%4)
		f = ani
	
	if time>FRAME_TIME:
		time = time - FRAME_TIME
		f += 1
		if (f-ani)>3:
			f = ani
	
	if position.x<8.0:
		ani = 8
		f = 8
	elif position.x>(get_viewport_rect().size.y-8.0):
		ani = 12
		f = 12
	if position.y<8.0:
		ani = 0
		f = 0
	elif position.y>(get_viewport_rect().size.y-8.0):
		ani = 4
		f = 4
	
	if f>=(ani+4):
		f = ani
	frame = f
	
	match ani:
		0:
			translate( Vector2(0,SPD*delta) )
		4:
			translate( Vector2(0,-SPD*delta) )
		8:
			translate( Vector2(SPD*delta,0) )
		12:
			translate( Vector2(-SPD*delta,0) )

	
func _ready():
	translate( get_viewport_rect().size / 2 )
	delay = randf()*RANDOM_TIME
	ani = 4 * (randi()%4)
	frame = ani

