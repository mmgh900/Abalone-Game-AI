extends Node

export var pieces_path : NodePath
onready var pieces = get_node(pieces_path)
onready var white_score = get_node('../Control/VBoxContainer/white-score')
onready var black_score = get_node('../Control/VBoxContainer/black-score')
onready var move_number = get_node('../Control/VBoxContainer/move-number')
var white_piece = preload("res://Scenes/White Piece.tscn")
var black_piece = preload("res://Scenes/Black Piece.tscn")
var rng = RandomNumberGenerator.new()
var state
var history = []
var historyIndex = 0
var max_depth = 2

func _ready():
	draw_complete_board(BoardManager.current_board)
	state = State.new(BoardManager.current_board, 0, 0)

func play():
	history.append(state)
	historyIndex = historyIndex + 1
	
	
	open_state(state, max_depth)
	print(state.children)
	state.evaluate()
	#state.print_eval()
	state = state.children[state.best_index]
	
	var res = Successor.calculate_successor(state, BoardManager.BLACK)
	rng.randomize()
	var rand = rng.randi_range(0, len(res) - 1)
	state = res[rand]
		 
	updtae_game(state)
	
func open_state(state: State, depth: int):
	
	state.depth = max_depth - depth
	if depth <= 0:
		return
	
	
	if state.depth % 2 == 0:
		state.children = Successor.calculate_successor(state, BoardManager.WHITE)
	else:
		state.children = Successor.calculate_successor(state, BoardManager.BLACK)
	

	for child in state.children:
		open_state(child, depth - 1)
		
func updtae_game(state: State):
	update_board(state.board)
	white_score.text = str(state.white_score)
	black_score.text = str(state.black_score)
	move_number.text = str(historyIndex)
		
func update_board(new_board):
	for child in pieces.get_children():
		child.queue_free()
	
	draw_complete_board(new_board)
	
func _input(ev):
	if Input.is_key_pressed(KEY_RIGHT):
		if (historyIndex < len(history) - 1):
			historyIndex = historyIndex + 1
			updtae_game(history[historyIndex])
	if Input.is_key_pressed(KEY_LEFT):
		if (historyIndex > 0):
			historyIndex = historyIndex - 1
			updtae_game(history[historyIndex])
	if Input.is_key_pressed(KEY_ENTER):
		play()
			
func draw_complete_board(board):
	var coordinates = Vector3(0, 0, 0)
	for cell_number in range(len(board)):
		if board[cell_number] == BoardManager.WHITE:
			coordinates = get_3d_coordinates(cell_number)
			var piece = white_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates
		elif board[cell_number] == BoardManager.BLACK:
			coordinates = get_3d_coordinates(cell_number)
			var piece = black_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates

func get_3d_coordinates(cell_number):
	if cell_number >= 0 and cell_number <= 4:
		return Vector3(-0.6 + cell_number * 0.3, 0.01, -1.04)
	elif cell_number >= 5 and cell_number <= 10:
		return Vector3(-0.75 + (cell_number - 5) * 0.3, 0.01, -0.78)
	elif cell_number >= 11 and cell_number <= 17:
		return Vector3(-0.9 + (cell_number - 11) * 0.3, 0.01, -0.52)
	elif cell_number >= 18 and cell_number <= 25:
		return Vector3(-1.05 + (cell_number - 18) * 0.3, 0.001, -0.26)
	elif cell_number >= 26 and cell_number <= 34:
		return Vector3(-1.2 + (cell_number - 26) * 0.3, 0.01, 0)
	elif cell_number >= 35 and cell_number <= 42:
		return Vector3(-1.05 + (cell_number - 35) * 0.3, 0.01, 0.26)
	elif cell_number >= 43 and cell_number <= 49:
		return Vector3(-0.9 + (cell_number - 43) * 0.3, 0.01, 0.52)
	elif cell_number >= 50 and cell_number <= 55:
		return Vector3(-0.75 + (cell_number - 50) * 0.3, 0.01, 0.78)
	else:
		return Vector3(-0.6 + (cell_number - 56) * 0.3, 0.01, 1.04)
	
