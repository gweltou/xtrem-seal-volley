extends Sprite

export var speed = 0.1

var original_height
var width


# Called when the node enters the scene tree for the first time.
func _ready():
	original_height = position.y
	width = get_rect().size.x


func _process(delta):
	position.x += speed
	
	if position.x > get_viewport().size.x + width:
		position.x = -width
		position.y = original_height + (randi() % 30) - 15
