extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var parts_container = $PartsSkeletonContainer
@onready var skeleton = $PartsSkeletonContainer/Skeleton2D

# cliff diving
var jumped = false

const initial_rotation_speed = 5
const base_tuck_multiplier = 2

var face_direction = 1 # 1 == right, -1 == left
var rotation_speed = 0
var is_tucked = false
var current_tuck_multiplier = 1
var is_twisting = false

func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	
	if jumped:
		velocity += get_gravity() * delta
	
	if Input.is_action_pressed("start_rotation"):
		rotation_speed = initial_rotation_speed
	
	# check if tucked #
	#if !is_twisting:
	if Input.is_action_just_pressed("tuck"):
		if is_twisting:
			animation_player.queue("tuck_transition")
		else:
			animation_player.play("tuck_transition")
		animation_player.queue("tuck")
		
	if Input.is_action_just_released("tuck"):
		if !is_twisting:
			animation_player.play_backwards("tuck_transition")

	# check if twisting #
	if Input.is_action_just_pressed("twist"):
		if is_tucked:
			animation_player.queue("straight_twist_transition")
		else:
			animation_player.play("straight_twist_transition")
		animation_player.get_animation("straight_twist").loop_mode = Animation.LOOP_PINGPONG
		animation_player.queue("straight_twist")
	if Input.is_action_just_released("twist"):
		if !is_tucked:
			animation_player.get_animation("straight_twist").loop_mode = Animation.LOOP_NONE
			animation_player.queue("straight_twist_transition_out")

	if is_tucked && is_twisting:
		# do something
		null
	
	elif is_tucked:
		var tuck_amount = 1
		if animation_player.current_animation == "tuck_transition":
			tuck_amount = animation_player.current_animation_position / animation_player.current_animation_length
			
		# tuck centre of mass offset #
		parts_container.position.x = face_direction * -28 * tuck_amount
		parts_container.position.y = 185 + (tuck_amount * 50)
		
		
		null
		
	elif is_twisting:
		null

		
	if animation_player.current_animation == "tuck_transition":
		current_tuck_multiplier = 1 + ((base_tuck_multiplier - 1) * (animation_player.current_animation_position / animation_player.current_animation_length))
	elif animation_player.current_animation == "tuck":
		current_tuck_multiplier = base_tuck_multiplier
	
	
	calculate_rotation(delta)
	move_and_slide()


func bounce():
	if (rotation_degrees > -30 && rotation_degrees < 30) && velocity.y < 1250:
		velocity.y += 50
	velocity *= -1


func calculate_rotation(delta):
	rotation += rotation_speed * current_tuck_multiplier * delta
	#if is_tucked:
		#rotation += rotation_speed * current_tuck_multiplier * delta
	#else:
		#rotation += rotation_speed * delta
		
func half_twist():
	face_direction *= -1

func change_direction():
	parts_container.scale.x = face_direction

func toggle_tuck():
	is_tucked = !is_tucked

func twist():
	is_twisting = true

func untwist():
	is_twisting = false
