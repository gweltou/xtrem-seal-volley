extends KinematicBody2D


export var ground_speed = 800
export var jump_force = 1000
export var gravity = 50
export var air_control = 0.5

var velocity = Vector2()
var touch_ground = true
var prev_position := Vector2()
var motion := Vector2()

# Vars set by level
var ball
var net_position
var floor_height = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	prev_position = position


func _process(delta):
	if ball.position.x > net_position:
		if ball.position.x + ball.velocity.x * 0.1 > position.x:
			move_right(delta)
		elif ball.position.x < position.x - 25:
			move_left(delta)
		else:
			if ball.velocity.y > 0 and ball.position.x < position.x - 8 \
			and ball.position.y < position.y - 20 \
			and ball.position.y + ball.velocity.y * 0.1 > 260 :
				jump()
			else:
				stop()
	else:
		var center_field = net_position + (get_viewport_rect().size.x - net_position) * 0.5
		if position.x < center_field - 32:
			move_right(delta)
		elif position.x > center_field + 32:
			move_left(delta)
		else:
			stop()
	
	if is_on_floor():
		velocity.x = clamp(velocity.x, -ground_speed, ground_speed)
	else:
		velocity.x = clamp(velocity.x, -ground_speed*0.8, ground_speed*0.8)
	
		$Shadow.global_position = Vector2(position.x, floor_height + 0.1 * (floor_height-position.y))


func _physics_process(delta):
	motion = position - prev_position
	prev_position = position
	
	var collision = move_and_slide(velocity, Vector2(0, -1))
	
	if not is_on_floor():
		velocity.y += gravity


func move_left(delta):
	if is_on_floor():
		velocity.x -= ground_speed * delta * 20
	else:
		velocity.x -= ground_speed * delta * 20 * air_control

func move_right(delta):
	if is_on_floor():
		velocity.x += ground_speed * delta * 20
	else:
		velocity.x += ground_speed * delta * 20 * air_control

func stop():
	if is_on_floor():
		velocity.x = 0

func jump():
	if is_on_floor():
		velocity.y = -jump_force
