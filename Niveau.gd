extends Node2D


var player1_scene = preload("res://Player.tscn")
var player2_scene = preload("res://Player2.tscn")
var ball_scene = preload("res://Ball.tscn")
var bot_scene = preload("res://Bot.tscn")

var player
var ball
var left_score = 0
var right_score = 0
var playing = true
var floor_height = 530
var spawned = []
onready var net_position = $Net.position.x

var in_menu = true
var selected_menu : Label
var timer = 0.0
onready var menu_pvp = $TopLayer/Menu/MenuPvP
onready var menu_pvb = $TopLayer/Menu/MenuPvB


# Called when the node enters the scene tree for the first time.
func _ready():
	$TopLayer/Menu.visible = true
	$TopLayer/LeftScore.visible = false
	$TopLayer/RightScore.visible = false
	selected_menu = menu_pvp
	
	player = player1_scene.instance()
	player.floor_height = floor_height
	player.z_as_relative = false
	player.z_index = 2
	player.connect("smash", self, "on_player_smash")
	player.connect("touch_ground", self, "on_player_touch_ground")
	
	ball = ball_scene.instance()
	ball.floor_height = floor_height
	ball.connect("touch_player", self, "on_ball_touch_player")
	ball.connect("touch_ground", self, "on_ball_touch_ground")	


func _process(delta):
	timer += delta
	$Sun.rotate(delta * 0.02)
	
	if in_menu:
		selected_menu.rect_rotation = 1.5 * sin(10 * timer)
		var scale = 1 + 0.2 * sin(7 * timer)
		selected_menu.rect_scale = Vector2(scale, scale)
		
		if Input.is_action_just_pressed("ui_left") and selected_menu != menu_pvp:
			selected_menu.rect_rotation = 0
			selected_menu.rect_scale = Vector2(1, 1)
			selected_menu = menu_pvp
		if Input.is_action_just_pressed("ui_right") and selected_menu != menu_pvb:
			selected_menu.rect_rotation = 0
			selected_menu.rect_scale = Vector2(1, 1)
			selected_menu = menu_pvb
		if Input.is_action_just_pressed("ui_accept"):
			if selected_menu == menu_pvp:
				var player2 = player2_scene.instance()
				player2.floor_height = floor_height
				player2.position.x = net_position * 1.5
				player2.connect("smash", self, "on_player_smash")
				player2.connect("touch_ground", self, "on_player_touch_ground")
				player.position.x = net_position * 0.5
				spawned.append(player)
				spawned.append(player2)
				add_child(player)
				add_child(player2)
			else:
				var bot = bot_scene.instance()
				bot.ball = ball
				bot.net_position = net_position
				bot.position.x = net_position + (get_viewport_rect().size.x - net_position) * 0.5
				bot.floor_height = floor_height
				spawned.append(bot)
				spawned.append(player)
				add_child(bot)
				add_child(player)
			
			ball.position = Vector2(net_position, 16)
			if randf() < 0.5:
				ball.velocity.x = 200
			else:
				ball.velocity.x = -200
			spawned.append(ball)
			add_child(ball)
			$TopLayer/Menu.visible = false
			$TopLayer/LeftScore.visible = true
			$TopLayer/RightScore.visible = true
			in_menu = false


func on_ball_touch_ground(position):
	if playing:
		playing = false
		var ball_velx
		if position.x < net_position:
			# Right player wins a point
			right_score += 1
			$TopLayer/RightScore.text = str(right_score)
			$AnimationPlayer.play("right_score")
			ball_velx = 200
		else:
			# Left player wins a point
			left_score += 1
			$TopLayer/LeftScore.text = str(left_score)
			$AnimationPlayer.play("left_score")
			ball_velx = -200
		if left_score >= 10 or right_score >= 10:
			game_over()
		else:
			yield(get_tree().create_timer(1.5), "timeout")
			ball.position = Vector2(net_position, 0)
			ball.velocity = Vector2(ball_velx, 0)
			playing = true


func game_over():
	$GameOverPlayer.play()
	Engine.time_scale = 0.2
	yield(get_tree().create_timer(2), "timeout")
	Engine.time_scale = 1
	for node in spawned:
		remove_child(node)
	in_menu = true
	$TopLayer/Menu.visible = true
	$TopLayer/LeftScore.visible = false
	$TopLayer/RightScore.visible = false
	

func on_player_touch_ground(position):
	pass


func on_ball_touch_player(position, normal, color):
	pass
	var line := Line2D.new()
	line.default_color = color
	line.width = 1
	line.add_point(position)
	line.add_point(position + normal*20)
	add_child(line)


func on_player_smash(direction):
	ball.velocity += direction * 2000
