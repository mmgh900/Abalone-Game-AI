extends Node

const max_depth: int = 2
const beam_search_k: int = 100
var rng = RandomNumberGenerator.new()
var trans_table = []
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
	
	
	# Chech to see if evaluted before
	for node in trans_table:
		if node["id"] == state.unique_id:
			state.opened_before = true
			state.eval = node["eval"]
	
	if state.opened_before:
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

func evalute_state(state: State):
	if state.opened_before:
		return state.eval
	if state.children == null: #if node is a leaf node
		state.eval = state.pure_eval
	elif state.depth % 2 == 0:
		state.eval = -INF
		
		for i in len(state.children):
			var child = state.children[i]
			child.alpha = state.alpha
			child.beta = state.beta
			var value = child.evaluate()
			
			if value > state.eval:
				state.eval = value
				state.best_child = child
				
			state.alpha = max(state.alpha, state.eval)
			if state.beta <= state.alpha:
				break
	else:
		state.eval = +INF
		for i in len(state.children):
			var child = state.children[i]
		
			child.alpha = state.alpha
			child.beta = state.beta
			var value = child.evaluate()
			
			if state.value < state.eval:
				state.eval = state.value
				state.best_child = state.child
			
			state.beta = min(state.beta, state.eval)
			if state.beta <= state.alpha:
				break

	trans_table.append({
		"id": state.unique_id,
		"eval": state.eval
	})
	return state.eval
	
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
	
func play():
	time_start = OS.get_ticks_msec()
	
	# Play the AI's turn
	open_state(current_state, max_depth)
	#current_state.evaluate()
	evalute_state(current_state)

	
	current_state = current_state.best_child
	
	time_now = OS.get_ticks_msec()
	var time_elapsed = time_now - time_start
	print(time_elapsed)
	

	# Add AI state to history
	history.append(current_state)
	
	
	# Play the Random's turn
	#var res = Successor.calculate_successor(current_state, BoardManager.BLACK)
	#rng.randomize()
	#var rand = rng.randi_range(0, len(res) - 1)
	#current_state = res[rand]
	
	# Add random state to history and updating the game
	#history.append(current_state)
	historyIndex = len(history) - 1
