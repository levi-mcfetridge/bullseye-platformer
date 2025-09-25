extends CharacterBody2D


@export var speed = 140.0
@export var JUMP_VELOCITY = -1000.0
@export var shot_velocity = 1480
#var direction = Vector2(In)
var gravity = 50
var bullet = true
var y = 0
var x = 20

var jumps = 3
var allow_jump = true
var has_double_jumped = false
var disabled = false

var initial_position

var is_wall_sliding = false
const wall_jump_pushback = 1000
const wall_slide_gravity = 100
var death_position
var ani_player


func _ready():
	ani_player = $AnimationPlayer
	initial_position = Vector2(position.x, position.y)
	$walk.play()
	$background.play()
func _process(_delta):
	if (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")) and is_character_grounded():
		if not $walk.is_playing():
			$walk.play()
	else:
		if $walk.is_playing():
			$walk.stop()
	
	if((Input.is_action_pressed("Right") or Input.is_action_pressed("Left")) and is_on_wall()):
		if not $"wall slide".is_playing():
			$"wall slide".play()
			
	else:
		if $"wall slide".is_playing():
			$"wall slide".stop()
	if(Input.is_action_pressed("Jump")):
		if not $jump.is_playing():
			$jump.play()
	if(Input.is_action_pressed("Shot")):
		if not $shot.is_playing():
			$shot.play()
	
	
	
		
	
func _physics_process(delta): 
	
	if Input.is_action_just_pressed("Shot"):
			shot()
	
	if Input.is_action_just_pressed("Jump"):
		if is_character_grounded():
			velocity.y = JUMP_VELOCITY
		elif(not has_double_jumped):
			velocity.y = JUMP_VELOCITY *.8
			#velocity.x = JUMP_VELOCITY *.8
			has_double_jumped = true
			if not $"dbl jump".is_playing():
				$"dbl jump".play()
			
	if is_character_grounded():
		has_double_jumped = false
		jumps = 0
			
	if(velocity==Vector2(0,0)):
		ani_player.play("idle_right")
	if velocity.x > 0:
		ani_player.play("run_right")
	elif not velocity.y == 0:
		ani_player.play("jump_right")
	if velocity.x < 0:
		ani_player.play("run_left")
	elif not velocity.y == 0:
		ani_player.play("jump_right")
	
	if Input.is_action_pressed("Left"):
		if velocity.x < -speed:
			velocity.x += 50
		else:
			velocity.x -=300
			
	elif Input.is_action_pressed("Right"):
		if velocity.x > speed:
			velocity.x -= 50
		else:
			velocity.x +=300
			
	else:
		if velocity.x >= 100:
			velocity.x -= 100
		if velocity.x < 100 && velocity.x > 0:
			velocity.x = 0
		if velocity.x <= -100:
			velocity.x += 100
		if velocity.x > -100 && velocity.x < 0:
			velocity.x = 0
		
	jump()
	wall_slide(delta)
	if(not disabled):
		move_and_slide()
	if(disabled):
		position = death_position
	reload()
	
	
func is_character_grounded():
	var collision = move_and_collide(Vector2(0, 1))
	return collision

	

func wall_slide(delta):
	if is_on_wall() and not is_character_grounded():
		if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false

	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
	
func jump():
	
	velocity.y += gravity
	if Input.is_action_just_pressed("Jump") && (allow_jump):
		allow_jump = false
		$"../JumpDelay".start()
		if is_character_grounded():
			velocity.y = JUMP_VELOCITY
		if is_on_wall() and Input.is_action_pressed("Right"):
			velocity.y = JUMP_VELOCITY
			velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("Left"):
			velocity.y = JUMP_VELOCITY
			velocity.x = wall_jump_pushback
	
	print(allow_jump)
			
func shot():
	if bullet:
		var shot_direction = -(get_global_mouse_position() - global_position).normalized()
		velocity.x = (shot_direction.x * shot_velocity)
		velocity.y = (shot_direction.y * shot_velocity)
		bullet = false
		$"../Camera2D/Ammo".self_modulate = Color(235, 0, 0, 255)
		$"../Camera2D/Ammo2".self_modulate = Color(235, 0, 0, 255)
		$"../Camera2D/Ammo3".self_modulate = Color(235, 0, 0, 255)
		$"../Camera2D/Ammo4".self_modulate = Color(235, 0, 0, 255)
		
func reload():
	if (Input.is_action_pressed("Reload")) && (bullet == false) && (velocity.x == 0) && (velocity.y == 0):
		bullet = true
		$"../Camera2D/Ammo".self_modulate = Color(1,1,1,1)
		$"../Camera2D/Ammo2".self_modulate = Color(1,1,1,1)
		$"../Camera2D/Ammo3".self_modulate = Color(1,1,1,1)
		$"../Camera2D/Ammo4".self_modulate = Color(1,1,1,1)
		$"../Camera2D/Ammo5".self_modulate = Color(1,1,1,1)
		$reload.play()
	

func _on_death_player_died():
	disabled = true
	death_position = position
	$death.play()
	Trans.trans_black()
	

func _on_death_player_reset():
	disabled = false
	teleport(initial_position)
	$"../Camera2D".offset = Vector2(0,0)
	Globals.camPos = 1020
	bullet = true
	$"../Camera2D/Ammo".self_modulate = Color(1,1,1,1)
	$"../Camera2D/Ammo2".self_modulate = Color(1,1,1,1)
	$"../Camera2D/Ammo3".self_modulate = Color(1,1,1,1)
	$"../Camera2D/Ammo4".self_modulate = Color(1,1,1,1)
	$"../Camera2D/Ammo5".self_modulate = Color(1,1,1,1)

func teleport(new_position):
	position = new_position
	


func _on_area_2d_body_entered(_body):
	if velocity.x > 0:
		
		var tween = get_tree().create_tween()
		tween.tween_property($"../Camera2D","offset",Vector2($"../Camera2D".position.x+Globals.camPos,0),1)
		Globals.camPos+=1020
	else:
		
		var tween = get_tree().create_tween()
		Globals.camPos-=1020
		tween.tween_property($"../Camera2D","offset",Vector2($"../Camera2D".position.x+Globals.camPos-1020,0),1)
	
	
func _on_jump_delay_timeout():
	allow_jump = true
	print('peen')
