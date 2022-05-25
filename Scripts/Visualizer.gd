extends Node

export var pieces_path : NodePath
onready var pieces = get_node(pieces_path)
onready var white_score = get_node('../Control/VBoxContainer/white-score')
onready var black_score = get_node('../Control/VBoxContainer/black-score')
onready var move_number = get_node('../Control/VBoxContainer/move-number')


var white_piece = preload("res://Scenes/White Piece.tscn")

var black_piece = preload("res://Scenes/Black Piece.tscn")
var PieceController = preload("res://Scripts/Piece Control.gd")
onready var pieceController = PieceController.new()

func _ready():
	update_game(BoardManager.current_state)
	
func update_game(state: State):
	update_board(state.board)
	white_score.text = str(state.white_score)
	black_score.text = str(state.black_score)
	move_number.text = str(BoardManager.historyIndex)
		
func update_board(new_board):
	for child in pieces.get_children():
		child.queue_free()
	
	draw_complete_board(new_board)
	
func _input(_ev):
	if Input.is_key_pressed(KEY_PAGEUP):
		if (BoardManager.historyIndex < len(BoardManager.history) - 1):
			BoardManager.historyIndex = BoardManager.historyIndex + 1
			update_game(BoardManager.history[BoardManager.historyIndex])

	if Input.is_key_pressed(KEY_PAGEDOWN):
		if (BoardManager.historyIndex > 0):
			BoardManager.historyIndex = BoardManager.historyIndex - 1
			update_game(BoardManager.history[BoardManager.historyIndex])
	
func draw_complete_board(board):
	var coordinates = Vector3(0, 0, 0)
	for cell_number in range(len(board)):
		if board[cell_number] == BoardManager.WHITE:
			coordinates = BoardManager.get_3d_coordinates(cell_number)
			var piece = white_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates
		elif board[cell_number] == BoardManager.BLACK:
			coordinates = BoardManager.get_3d_coordinates(cell_number)
			var piece = black_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates
