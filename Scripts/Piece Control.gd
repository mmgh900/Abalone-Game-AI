extends Reference

class_name PieceController

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event.button_index == BUTTON_LEFT and event.pressed == true:
		print('entered')


func on_enter(node: Node):
	var new_material = load("res://Materials/test_ball_green.tres")
	node.get_node("MeshInstance").material_override = new_material


func on_exit(node: Node):
	var new_material = load("res://Materials/test_ball_white.tres")
	node.get_node("MeshInstance").material_override = new_material
