extends CharacterBody2D


@export var speed = 100
@export var JUMP_VELOCITY = -600
@export var shot_velocity = 1200

var gravity = 70
var bullet = true

var has_double_jumped = false
var disabled = false



var is_wall_sliding = false
const wall_jump_pushback = 100
const wall_slide_gravity = 100
var death_position
var initial_position

func _ready():
	initial_position = Vector2(position.x, position.y)

func _physics_process(delta): 
	print(initial_position)

	if Input.is_action_just_pressed("Shot"):
			shot()
	
	if Input.is_action_just_pressed("Jump"):
		if is_character_grounded():
			velocity.y = JUMP_VELOCITY
		elif(not has_double_jumped):
			velocity.y = JUMP_VELOCITY *.8
			has_double_jumped = true
			
	if is_character_grounded():
		has_double_jumped = false
			
		
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
		position = initial_position
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
	if Input.is_action_just_pressed("Jump"):
		if is_character_grounded():
			velocity.y = JUMP_VELOCITY
		if is_on_wall() and Input.is_action_pressed("Right"):
			velocity.y = JUMP_VELOCITY
			velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("Left"):
			velocity.y = JUMP_VELOCITY
			velocity.x = wall_jump_pushback
			
func shot():
	if bullet:
		var shot_direction = -(get_global_mouse_position() - position).normalized()
		velocity.x = (shot_direction.x * shot_velocity)
		velocity.y = (shot_direction.y * shot_velocity)
		#bullet = false
		

func reload():
	if (Input.is_action_pressed("Reload")) && (bullet == false) && (velocity.x == 0) && (velocity.y == 0):
		bullet = true
		print('reload')
	

func _on_death_player_died():
	disabled = true
	print('died')
	death_position = position
	

func _on_death_player_reset():
	disabled = false
	teleport(initial_position)

func teleport(new_position):
	position = new_position
