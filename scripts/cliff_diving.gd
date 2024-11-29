extends Node2D

@onready var camera = $Camera2D
@onready var stickman = %Stickman
@onready var cliff = $Cliff
@onready var water = $Water

# UI Elements #
@onready var total_flips_label = $UI/HBoxContainer/TotalFlips
@onready var total_twists_label = $UI/HBoxContainer/TotalTwists
@onready var entry_score_label = $UI/HBoxContainer/EntryScore
@onready var total_score_label = $UI/TotalScore

#@onready var INITIAL_POSITION = stickman.position
@onready var WATER_HEIGHT = water.global_position.y

const CLIFF_HEIGHT_METRES_TO_PIXELS = 42 # assumes stickman is 75 px and 1.8m #

const LEVELS = {
	1: {
		"pose": {
			"face_direction": -1,
			"initial_rotation_direction": -1,
			"handstand_entry": false
		},
		"cliff_height": 20,
		"objective": {
			"flips": 2,
			"twists": 0,
			"entry": 7.0
		}
	},
	2: {
		
	}
}

var current_level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var pose = LEVELS.get(current_level).get("pose")
	stickman.load_pose(pose)
	cliff.global_position.y = WATER_HEIGHT - (LEVELS.get(current_level).get("cliff_height") * CLIFF_HEIGHT_METRES_TO_PIXELS)
	if pose.get("handstand_entry"):
		stickman.position.y = cliff.position.y - 59
	else:
		stickman.position.y = cliff.position.y - 36
	var desired_camera_height = WATER_HEIGHT - stickman.position.y + 300
	camera.zoom.y = camera.get_viewport_rect().size.y / desired_camera_height
	camera.zoom.x = camera.zoom.y
	camera.position = Vector2(stickman.position.x + (500 * (1 / camera.zoom.x)), (WATER_HEIGHT + stickman.position.y) / 2)
	#print(camera.zoom)
	#print(camera.get_viewport_rect().size)
	#print("water: ", WATER_HEIGHT, ", stickman: ", stickman.position, ", camera: ", camera.position)
	#camera.zoom.x = camera.zoom.y
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("reset_game"):
		#get_tree().reload_current_scene()
		reset_stickman()
	if Input.is_action_just_pressed("add_height"):
		add_height()
	if Input.is_action_just_pressed("reduce_height"):
		reduce_height()
	total_flips_label.text = "Flips:  " + str(stickman.total_rotations)
	total_twists_label.text = "Twists:  " + str(stickman.total_twists)
	entry_score_label.text = "Entry:  " + str(snapped(stickman.entry_score, 0.01) if stickman.entry_score != 0 else "")
	
	if stickman.total_score != 0:
		total_score_label.text = "Total Score:  " + str(snapped(stickman.total_score, 0.1))
	else:
		total_score_label.text = ""
	

func reset_stickman():
	#stickman.reset_attributes()
	stickman.get_tree().reload_current_scene()
	#stickman.position = INITIAL_POSITION
	stickman.rotation = 0
	stickman.velocity = Vector2(0, 0)

func add_height():
	stickman.position.y -= 50
	cliff.position.y -= 50
	
func reduce_height():
	stickman.position.y += 50
	cliff.position.y += 50
