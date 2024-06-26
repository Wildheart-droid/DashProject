extends CharacterBody2D

var speed = 300.0
var jump_velocity = -400.0

var dash_speed = 35000
var can_dash = false
var is_dashing = false

var axis = Vector2()
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_time :Timer = $DashTimer

func _ready():
	animation_tree.active = true
	
func _physics_process(delta):
	get_input_axis()
	dash(delta)
	if not is_on_floor() or !is_dashing:
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !is_dashing:
		velocity.y = jump_velocity
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	update_animations(direction)
	move_and_slide()

func get_input_axis():
	axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	axis = axis.normalized()
	
	if axis == Vector2.ZERO:
		if animated_sprite.flip_h:
			axis.x = -1
		else:
			axis.x = 1

func update_animations(direction):
	#sets the animation and direction of character
	animation_tree.set("parameters/move/blend_position", axis.x)
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

func dash(delta):
	if !can_dash and is_on_floor():
		can_dash = true
	if can_dash:
		if Input.is_action_just_pressed("Dash"):
			velocity = Vector2.ZERO
			dash_time.start()
			is_dashing = true
			can_dash = false
			#experimenting with how much distance going either only using x or y 
			if axis.y and !axis.x:
				velocity.y = axis.y * 32000 * 0.8 * delta
			elif axis.x and !axis.y:
				velocity.x = axis.x * 37000 * 1.1 * delta
			#regular dash logic
			else:
				velocity.x = axis.x * dash_speed * 1.2 * delta
				velocity.y = axis.y * dash_speed * 0.9 * delta


func _on_dash_timer_timeout():
	is_dashing = false
	if velocity.length() >= speed:
		velocity.x *= 0.45
		velocity.y *= 0.23
