extends Node

const max_depth: int = 2
const beam_search_k: int = 100
var rng = RandomNumberGenerator.new()


var history: Array = []
var historyIndex: int = 0
var time_start: float = 0
var time_now: float = 0

var current_state: State
var neighbors = {}
enum {EMPTY, BLACK, WHITE} # used to represent the board
enum {L, UL, UR, R, DR, DL} # used to represent the directions of neighbors


func _ready():
	init_board()

func init_board():
	var file = File.new()
	file.open("res://adjacency_lists.json", File.READ)
	var raw_data = file.get_as_text()
	var adjacency_lists = parse_json(raw_data)
	file.close() # reading the file that specifies the adjacency lists and converting it to a dictionary
	var board = []
	for cell_number in range(61):
		var cell_value = EMPTY
		if (cell_number >= 0 and cell_number <= 10) or (cell_number >= 13 and cell_number <= 15):
			cell_value = BLACK
		elif (cell_number >= 45 and cell_number <= 47) or (cell_number >= 50 and cell_number <= 60):
			cell_value = WHITE
		else:
			cell_value = EMPTY # determining the value of the current board cell
		
		
		board.append(cell_value)
		neighbors[cell_number] = []
		for neighbor in adjacency_lists[str(cell_number)]:
			neighbors[cell_number].append(int(neighbor))
	current_state = State.new(board, 0, 0)	
	history.append(current_state)
	
func check_cluster(board, cell_number, piece, cluster_length, cluster_direction):
	if board[cell_number] != piece:
		return false
	
	var neighbor = cell_number
	for i in range(1, cluster_length):
		neighbor = neighbors[neighbor][cluster_direction]
		if neighbor == -1:
			return false
		elif board[neighbor] != piece:
			return false
	return true
	
func get_stats(board, cell_number, piece, cluster_length, cluster_direction):
	var num_side_pieces = 0
	var num_opponent_pieces = 0
	var piece_has_space = false
	var opponent_has_space = false
	var is_sandwich = false
	
	var current_point = cell_number
	for i in range(cluster_length + cluster_length):
		if board[current_point] == piece:
			if num_opponent_pieces > 0:
				is_sandwich = true
				break
			else:	
				num_side_pieces += 1
				if neighbors[current_point][cluster_direction] != -1:
					if board[neighbors[current_point][cluster_direction]] == EMPTY and i == cluster_length - 1:
						piece_has_space = true
						break
					
		elif board[current_point] == EMPTY:
			continue
			
		else: # opponent
			if num_side_pieces == cluster_length:
				num_opponent_pieces += 1
			if neighbors[current_point][cluster_direction] != -1:
				if board[neighbors[current_point][cluster_direction]] == EMPTY and piece_has_space == false and num_side_pieces == cluster_length and i != cluster_length + cluster_length - 1:
					opponent_has_space = true
					break
		
		current_point = neighbors[current_point][cluster_direction]
		if current_point == -1:
			break
	return {"number of side pieces" : num_side_pieces, "number of opponent pieces" : num_opponent_pieces, \
			"piece has space" : piece_has_space, "opponent has space" : opponent_has_space, 
			"is sandwich" : is_sandwich}
	
func open_state(state: State, depth: int):

	state.depth = max_depth - depth
	if depth <= 0:
		return
	
	
	if state.depth % 2 == 0:
		state.children = Successor.calculate_successor(state, BoardManager.WHITE)
	else:
		state.children = Successor.calculate_successor(state, BoardManager.BLACK)
	
	state.children.sort_custom(self, "sort_based_on_pure_eval")
	for i in range(min(beam_search_k, len(state.children))):
		var child = state.children[i]
		open_state(child, depth - 1)

func sort_based_on_pure_eval(a: State, b: State):
	if a.pure_eval > b.pure_eval:
		return true
	return false

func play():
	time_start = OS.get_ticks_msec()
	# Play the AI's turn
	open_state(current_state, max_depth)
	current_state.evaluate()
	current_state = current_state.best_child
	
	time_now = OS.get_ticks_msec()
	var time_elapsed = time_now - time_start
	print(time_elapsed)
	

	# Add AI state to history
	history.append(current_state)
	
	
	# Play the Random's turn
	var res = Successor.calculate_successor(current_state, BoardManager.BLACK)
	rng.randomize()
	var rand = rng.randi_range(0, len(res) - 1)
	current_state = res[rand]
	
	# Add random state to history and updating the game
	history.append(current_state)
	historyIndex = len(history) - 1
