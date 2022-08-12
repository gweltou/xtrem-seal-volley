extends KinematicBody2D


export(int) var player_num
export var ground_speed = 800
export var jump_force = 1000
export var gravity = 50
export var air_control = 0.5

var velocity = Vector2()
var touch_ground = true
var prev_position := Vector2()
var motion := Vector2()
var ball_near = false

onready var ct_left = "p%d_left" % player_num
onready var ct_right = "p%d_right" % player_num
onready var ct_up = "p%d_up" % player_num
onready var ct_down = "p%d_down" % player_num
onready var ct_jump = "p%d_jump" % player_num
onready var sprite := $AnimatedSprite

# Vars set by level
var floor_height = 0


signal smash(direction)
signal touch_ground(position)


# Called when the node enters the scene tree for the first time.
func _ready():
	prev_position = position


func _process(_delta):
	var direction = Input.get_vector(ct_left, ct_right, ct_up, ct_down)
	
	if is_on_floor():
		if direction.x == 0:
			velocity.x = 0
			sprite.stop()
			sprite.frame = 0
		else:
			velocity.x += direction.x * ground_speed * 0.2
			velocity.x = clamp(velocity.x, -ground_speed, ground_speed)
			sprite.play("walk")
	else:
		velocity.x += direction.x * ground_speed * air_control * 0.2
		velocity.x = clamp(velocity.x, -ground_speed*0.8, ground_speed*0.8)
	
	
	if Input.is_action_just_pressed(ct_jump):
		if ball_near:
			emit_signal("smash", direction)
			$AudioStreamPlayer2D.play()
		elif is_on_floor():
			velocity.y = -jump_force
			sprite.play("jump")
	
	$Shadow.global_position = Vector2(position.x, floor_height + 0.1 * (floor_height-position.y))
	


func _physics_process(_delta):
	motion = position - prev_position
	prev_position = position
	
	var in_air = not is_on_floor()
	
	move_and_slide(velocity, Vector2(0, -1))
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Ground" and in_air:
			sprite.play("jump", true)
			emit_signal("touch_ground", position)
	
	if not is_on_floor():
		velocity.y += gravity


func _on_Area2D_body_entered(body):
	if body.name == "Ball":
		ball_near = true
#		$Sprite.set_modulate(Color(1, 0, 0, 1))


func _on_Area2D_body_exited(body):
	if body.name == "Ball":
		ball_near = false
#		$Sprite.set_modulate(Color(1, 1, 1, 1))
