extends Node

var selector_positions = [14]
var cluster_direction = 5

var SelectorPiece = preload("res://Scenes/Selector Piece.tscn")
onready var Visualizer = get_node("/root/Game/Visualizer")
var possible_move_directions = []
func _ready():
	_draw_selector()
func _input(event):
	if Input.is_key_pressed(KEY_W) and Input.is_key_pressed(KEY_SHIFT):
		set_selector_position(BoardManager.UL)
		_draw_selector()
	elif Input.is_key_pressed(KEY_S) and Input.is_key_pressed(KEY_SHIFT):
		set_selector_position(BoardManager.DR)
		_draw_selector()
	elif Input.is_key_pressed(KEY_W):
		set_selector_position(BoardManager.UR)
		_draw_selector()
	elif Input.is_key_pressed(KEY_D):
		set_selector_position(BoardManager.R)
		_draw_selector()
	elif Input.is_key_pressed(KEY_A):
		set_selector_position(BoardManager.L)
		_draw_selector()
	elif Input.is_key_pressed(KEY_S):
		set_selector_position(BoardManager.DL)
		_draw_selector()
	elif Input.is_key_pressed(KEY_1):
		make_cluster(1)
		_draw_selector()
	elif Input.is_key_pressed(KEY_2):
		make_cluster(2)
		_draw_selector()
	elif Input.is_key_pressed(KEY_3):
		make_cluster(3)
		_draw_selector()
	elif Input.is_key_pressed(KEY_DOWN) and Input.is_key_pressed(KEY_SHIFT):
		preform_move(BoardManager.DL)
	elif Input.is_key_pressed(KEY_UP) and Input.is_key_pressed(KEY_SHIFT):
		preform_move(BoardManager.UL)
	elif Input.is_key_pressed(KEY_DOWN):
		preform_move(BoardManager.DR)
	elif Input.is_key_pressed(KEY_UP):
		preform_move(BoardManager.UR)
	elif Input.is_key_pressed(KEY_RIGHT):
		preform_move(BoardManager.R)
	elif Input.is_key_pressed(KEY_LEFT):
		preform_move(BoardManager.L)
		
func _draw_selector():
	var all_black = true
	for position in selector_positions:
		var piece = SelectorPiece.instance()
		piece.translation = BoardManager.get_3d_coordinates(position)
		self.add_child(piece)
		if BoardManager.current_state.board[position] != BoardManager.BLACK:
			all_black = false
			
	var material = get_child(0).get_node("StaticBody/MeshInstance").get_surface_material(0)
	
	if all_black:
		material.albedo_color = "#00ff00"
		var sorted_cluster = selector_positions.duplicate(true)
		sorted_cluster.sort()
		possible_move_directions = Move.get_possible_move_directions(len(selector_positions), cluster_direction)
		
	else:
		material.albedo_color = "#ff0000"
		possible_move_directions = []
	
func set_selector_position(direction):
	var last_position = selector_positions[0]
	var neighbor = BoardManager.neighbors[last_position][direction]
	if neighbor != -1:
		clear_selectors()
		selector_positions.append(neighbor)
	else: 
		if direction == BoardManager.UR:
			set_selector_position(BoardManager.UL)
		if direction == BoardManager.DL:
			set_selector_position(BoardManager.DR)

func make_cluster(size: int):
	var last_position = selector_positions[0]
	clear_selectors()
	selector_positions.append(last_position)
	if BoardManager.current_state.board[last_position] != BoardManager.BLACK or size == 1:
		return
	cluster_direction = next_cluster_direction()
	var second_piece_position = BoardManager.neighbors[last_position][cluster_direction]
	if second_piece_position != -1:
		if size == 2:
			selector_positions.append(second_piece_position)
			return
			
		var third_piece_position = BoardManager.neighbors[second_piece_position][cluster_direction]
		if third_piece_position != -1:
			selector_positions.append(second_piece_position)
			selector_positions.append(third_piece_position)
		
func clear_selectors():
	selector_positions.clear()
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free()
	
func next_cluster_direction():
	if cluster_direction == 5:
		return 0
	else:
		return cluster_direction + 1

func preform_move(direction):
	if (not direction in possible_move_directions):
		return
	else:
		var legal_status = []
		legal_status = Move.is_legal(BoardManager.current_state, selector_positions[0], BoardManager.BLACK, len(selector_positions), cluster_direction, direction)
		if legal_status["move is legal"] == true:
			var new_state = State.new(BoardManager.current_state.board, BoardManager.current_state.black_score, BoardManager.current_state.white_score)
			Move.execute(new_state, selector_positions[0], BoardManager.BLACK, len(selector_positions), cluster_direction, direction, legal_status)
			BoardManager.history.append(new_state)
			BoardManager.current_state = new_state
			BoardManager.play()
			Visualizer.update_game(BoardManager.current_state)
			_draw_selector()
