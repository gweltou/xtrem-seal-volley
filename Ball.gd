extends KinematicBody2D


export var gravity = 500
export var restitution := 1.0
export var max_speed = 1000

var velocity := Vector2()
var motion := Vector2()
var prev_position := Vector2()
var _rotation = 0
var touch_ground = false
var _restitution
var radius

var floor_height = 0

signal touch_player(position, normal, color)
signal touch_ground(position)


func _ready():
	radius = $CollisionShape2D.shape.radius


func _process(delta):
	$Shadow.global_position = Vector2(position.x, floor_height + 0.1 * (floor_height-position.y))


func _physics_process(delta):
	motion = position - prev_position
	prev_position = position
	
	touch_ground = false
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		_restitution = restitution
		if collision.collider.name == "Player":
			var dot_product = motion.dot(collision.collider.motion)
			velocity += collision.normal * dot_product * 4
		if collision.collider.name == "Ground":
			emit_signal("touch_ground", position)
			touch_ground = true
			_restitution = 0.6 * restitution
			if velocity.length_squared() < 4000:
				velocity.y = 0
		
		velocity = velocity.bounce(collision.normal) * _restitution
		velocity = velocity.clamped(max_speed)
		_rotation = (velocity.x / 128) * 2 * PI * delta
	
	$Ball64.rotate(_rotation)
	
	if not touch_ground:
		velocity.y += gravity * delta
	
	
