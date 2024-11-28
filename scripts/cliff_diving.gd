extends Node2D

@onready var stickman = %Stickman
@onready var cliff = $Cliff


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("reset_game"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("add_height"):
		add_height()
	if Input.is_action_just_pressed("reduce_height"):
		reduce_height()

func add_height():
	stickman.position.y -= 50
	cliff.position.y -= 50
	
func reduce_height():
	stickman.position.y += 50
	cliff.position.y += 50
