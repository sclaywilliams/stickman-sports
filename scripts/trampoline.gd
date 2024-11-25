extends Area2D

@onready var stickman = %Stickman


func _on_area_entered(area):
	stickman.bounce()
