extends Area2D

@onready var stickman = %Stickman
@onready var water_surface = $CollisionShape2D2
func _on_area_entered(area):
	stickman.enter_water(water_surface.global_position.y)


func _on_area_exited(area):
	stickman.exit_water()
