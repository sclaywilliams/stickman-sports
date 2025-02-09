extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var parts_container = $PartsSkeletonContainer
@onready var skeleton = $PartsSkeletonContainer/Skeleton2D
#@onready var upwards_raycast = $PartsSkeletonContainer/UpwardsRayCast
@onready var dive_area = $PartsSkeletonContainer/DiveArea

# physics constants #
const bouyancy = 1000
# 1 pixel == 4.675mm #

# cliff diving
var handstand_entry = false
var jumped = false
var in_water = false
var at_surface = false
var water_surface_coordinate = 0
var underwater_rotation_speed = 0

var initial_rotation_direction = 1 # 1 == clockwise, -1 == anticlockwise
const initial_rotation_speed = 5
const base_tuck_multiplier = 2.8

var total_rotations = 0.0
var total_twists = 0.0
var entry_score = 0.0
var total_score = 0.0

var face_direction = 1 # 1 == right, -1 == left
var rotation_speed = 0
var is_tucked = false
var current_tuck_multiplier = 1
var is_twisting = false
var is_piked = false

func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	
	
		
	if in_water:

		# reset everything to surface conditions #
		if position.y <= water_surface_coordinate && velocity.y < 0:
			at_surface = true
			velocity = Vector2(0, 0)
			rotation = 0
			position.y = water_surface_coordinate

		# underwater motion #
		if !at_surface:
			velocity.y = velocity.y * (1 - delta * 5) - bouyancy * delta
			velocity.x *= 0.5
			var old_rotation = rotation_degrees
			if rotation != 0:
				rotation += underwater_rotation_speed * delta
			if old_rotation <= 0 && rotation_degrees > 0 || old_rotation >= 0 && rotation_degrees < 0:
				rotation = 0
			if rotation_degrees > -45 && rotation_degrees < 45 && velocity.y < 0 && animation_player.current_animation != "default":
				parts_container.scale.x = face_direction
				#if animation_player.current_animation != "dive_entry":
				animation_player.play("default")
				#else:
				#animation_player.play_backwards("dive_entry_transition")
				#animation_player.queue("default")
			move_and_slide()
		return
	if !jumped:
		if Input.is_action_just_pressed("change_orientation") && !Input.is_action_pressed("prep_jump"):
			face_direction *= -1
			change_direction()
		if Input.is_action_just_pressed("change_initial_rotation") && !Input.is_action_pressed("prep_jump"):
			initial_rotation_direction *= -1
			#print(initial_rotation_direction)
		if Input.is_action_just_pressed("handstand") && !Input.is_action_pressed("prep_jump"):
			if !handstand_entry:
				animation_player.play("handstand")
				rotation_degrees = 180
				position.y -= 23
				#position.y -= 60
				handstand_entry = true
			elif handstand_entry:
				animation_player.play("default")
				rotation_degrees = 0
				position.y += 23
				#position.y += 60
				handstand_entry = false
			
		if Input.is_action_just_pressed("prep_jump"):
			if handstand_entry:
				animation_player.play("handstand_prep")
				animation_player.queue("handstand_prep_reverse")
			elif !handstand_entry:
				if face_direction * initial_rotation_direction > 0:
					animation_player.play("prep_frontflip")
					animation_player.queue("prep_frontflip_reverse")
				elif face_direction * initial_rotation_direction < 0:
					animation_player.play("prep_backflip")
					animation_player.queue("prep_backflip_reverse")
		if Input.is_action_just_released("prep_jump"):
			var jump_power = animation_player.current_animation_position / animation_player.current_animation_length
			if animation_player.current_animation != "prep_frontflip" && animation_player.current_animation != "prep_backflip" && animation_player.current_animation != "handstand_prep":
				jump_power = 1 - jump_power
			if handstand_entry:
				velocity.x = 50 + 100
				velocity.y = (100 + 100 * jump_power) * -1
				animation_player.play("handstand_prep_release")
				animation_player.queue("default")
			else:
				velocity.x = 50 + 100 * jump_power
				velocity.y = (100 + 300 * jump_power) * -1
				animation_player.play("default")
			rotation_speed = initial_rotation_speed * jump_power * initial_rotation_direction
			jumped = true
		
		if handstand_entry:
			var prep_amount = 0
			if animation_player.current_animation == "handstand_prep":
				prep_amount = animation_player.current_animation_position / animation_player.current_animation_length
			elif animation_player.current_animation == "handstand_prep_reverse":
				prep_amount = 1 - animation_player.current_animation_position / animation_player.current_animation_length
			#elif animation_player.current_animation == "handstand_prep_release":
				#prep_amount = 1 - animation_player.current_animation_position / animation_player.current_animation_length
				
			# handstand centre of mass offset #
			parts_container.position.x = face_direction * -25 * prep_amount
			parts_container.position.y = 185 + -1 * prep_amount * 20
			#position.x += face_direction * -25 * prep_amount
			#position.y += -1 * prep_amount * 10
	
	elif jumped:
		# gravity #
		velocity += get_gravity() * delta
	
		
			
		#if Input.is_action_pressed("tuck") && Input.is_action_pressed("twist"):
			#animation_player.get_animation("tucked_twist").loop_mode = Animation.LOOP_PINGPONG
			#if animation_player.current_animation != "tucked_twist":
				#animation_player.play("tucked_twist")
		#else:
		animation_player.get_animation("tucked_twist").loop_mode = Animation.LOOP_NONE
		# check if tucked #
		if Input.is_action_just_pressed("tuck"):
			if is_twisting:
				animation_player.queue("tuck_transition")
			else:
				animation_player.play("tuck_transition")
			animation_player.queue("tuck")
			
		if Input.is_action_just_released("tuck"):
			if !is_twisting:
				animation_player.play_backwards("tuck_transition")
		
		# check if piked #
		if Input.is_action_just_pressed("pike"):
			if is_twisting:
				animation_player.queue("pike_transition")
			else:
				animation_player.play("pike_transition")
			animation_player.queue("pike")
			
		if Input.is_action_just_released("pike"):
			if !is_twisting:
				animation_player.play_backwards("pike_transition")

		# check if twisting #
		if Input.is_action_just_pressed("twist"):
			if is_tucked || is_piked:
				animation_player.queue("straight_twist_transition")
			else:
				animation_player.play("straight_twist_transition")
			animation_player.get_animation("straight_twist").loop_mode = Animation.LOOP_PINGPONG
			animation_player.queue("straight_twist")
		if Input.is_action_just_released("twist"):
			animation_player.get_animation("straight_twist").loop_mode = Animation.LOOP_NONE
			if !is_tucked:
				animation_player.queue("straight_twist_transition_out")
		
		if animation_player.current_animation == "" && (180 - rotation_degrees > 0):
			animation_player.play("dive_entry_transition")
			animation_player.queue("dive_entry")

		
		elif is_tucked:
			var tuck_amount = 1
			if animation_player.current_animation == "tuck_transition":
				tuck_amount = animation_player.current_animation_position / animation_player.current_animation_length
				
			# tuck centre of mass offset #
			parts_container.position.x = face_direction * -28 * tuck_amount
			parts_container.position.y = 185 + (tuck_amount * 40)
			
		elif is_piked:
			var tuck_amount = 1
			if animation_player.current_animation == "pike_transition":
				tuck_amount = animation_player.current_animation_position / animation_player.current_animation_length
				
			# tuck centre of mass offset #
			parts_container.position.x = face_direction * -100 * tuck_amount
			parts_container.position.y = 185 + (tuck_amount * 40)

		
		match animation_player.current_animation:
			"tuck_transition":
				current_tuck_multiplier = 1 + ((base_tuck_multiplier - 1) * (animation_player.current_animation_position / animation_player.current_animation_length))
			"tuck":
				current_tuck_multiplier = base_tuck_multiplier
			"pike_transition":
				current_tuck_multiplier = (1 + ((base_tuck_multiplier - 1) * (animation_player.current_animation_position / animation_player.current_animation_length))) * 0.8
			"pike":
				current_tuck_multiplier = base_tuck_multiplier * 0.8
			"dive_entry_transition":
				current_tuck_multiplier = 1 - 0.3 * (animation_player.current_animation_position / animation_player.current_animation_length)
			"dive_entry":
				current_tuck_multiplier = 0.7
			_:
				current_tuck_multiplier = 1
		
		calculate_rotation(delta)
		move_and_slide()


func bounce():
	if (rotation_degrees > -30 && rotation_degrees < 30) && velocity.y < 1250:
		velocity.y += 50
	velocity *= -1


func calculate_rotation(delta):
	var old_rotation = rotation_degrees
	rotation += rotation_speed * current_tuck_multiplier * delta
	#print("old: ", old_rotation, " | new: ", rotation_degrees)
	if initial_rotation_direction > 0:
		if old_rotation <= -90 && rotation_degrees > -90 || old_rotation <= 90 && rotation_degrees > 90:
			total_rotations += 0.5
	elif initial_rotation_direction < 0:
		if old_rotation >= -90 && rotation_degrees < -90 || old_rotation >= 90 && rotation_degrees < 90:
			total_rotations += 0.5
		#print("rotations: ", total_rotations)
	#if is_tucked:
		#rotation += rotation_speed * current_tuck_multiplier * delta
	#else:
		#rotation += rotation_speed * delta
		
func half_twist():
	face_direction *= -1
	total_twists += 0.5
	#print("twists: ", total_twists)

func change_direction():
	parts_container.scale.x = face_direction

func toggle_tuck():
	is_tucked = !is_tucked
	
func toggle_pike():
	is_piked = !is_piked

func twist():
	is_twisting = true

func untwist():
	is_twisting = false
	
func calculate_entry_score():
	var score = 10 * (abs((90 - abs(rotation_degrees))) / 90)
	if is_tucked || is_twisting:
		var penalty = 0.5
		if animation_player.current_animation == "twist_transition" || animation_player.current_animation == "tuck_transition":
			penalty = (animation_player.current_animation_position / animation_player.current_animation_length) / 2
		score *= 1 - penalty
	return score
	
func enter_water(water_surface):
	water_surface_coordinate = water_surface
	in_water = true
	
	# calculate underwater animation #
	underwater_rotation_speed = (0 - abs(rotation_degrees) / 180) * 5 * 800/velocity.y
	if rotation_degrees < 0:
		underwater_rotation_speed *= -1
	
	# calculate and print score #
	entry_score = calculate_entry_score()
	total_score = entry_score * (0.5 + total_rotations) * (1 + total_twists)
	#print("Total Flips: ", total_rotations, " | Total Twists: ", total_twists, " | Entry Score: ", snapped(entry_score, 0.01))
	#print("Total Score: ", snapped(total_score, 0.1),)
	
func exit_water():
	return
	
func load_pose(pose):
	face_direction = pose.get("face_direction")
	parts_container.scale.x = pose.get("face_direction")
	initial_rotation_direction = pose.get("initial_rotation_direction")
	handstand_entry = pose.get("handstand_entry")
	if handstand_entry:
		animation_player.play("handstand")
		rotation_degrees = 180
		position.y -= 23

func reset_attributes():
	jumped = false
	in_water = false
	animation_player.play("default")

	
