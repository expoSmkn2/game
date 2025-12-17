extends Area2D

var entered = false

func _on_body_entered(body: CharacterBody2D) -> void:
	entered = true

func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	entered = false
	
func _process(delta: float) -> void:
	if entered == true:
		if Input.is_action_just_pressed("interact"):
			get_tree().change_scene_to_file("res://Main.tscn")
