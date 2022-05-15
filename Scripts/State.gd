extends Reference

class_name State

var board = []
var black_score = 0
var white_score = 0
var best_child
var best_index
var children = null
var depth = 0
var rng = RandomNumberGenerator.new()
var eval
var alpha = -INF
var beta = +INF

	
const gravity = [
			4, 4, 4, 4, 4,
		  4, 3, 3, 3, 3, 4,
		4, 3, 2, 2, 2, 3, 4,
	   4, 3, 2, 1, 1, 2, 3, 4,
	 4, 3, 2, 1, 0, 1, 2, 3, 4,
	   4, 3, 2, 1, 1, 2, 3, 4,
		4, 3, 2, 2, 2, 3, 4,
		  4, 3, 3, 3, 3, 4,
			4, 4, 4, 4, 4,
]

func _init(board, black_score, white_score):
	self.black_score = black_score
	self.white_score = white_score
	
	for cell in board:
		self.board.append(cell)

func increase_score(piece):
	if piece == BoardManager.BLACK:
		self.black_score += 1
	elif piece == BoardManager.WHITE:
		self.white_score += 1

func evaluate():
	if children == null: #if node is a leaf node
		var score_difference = white_score - black_score
		var sum_gravity = 0
		rng.randomize()
		var rand_epslion = rng.randf()
		for i in range(len(board)):
			if board[i] == BoardManager.BLACK:
				sum_gravity += gravity[i]
			elif board[i] == BoardManager.WHITE:
				sum_gravity -= gravity[i]

		eval = score_difference * 100 + sum_gravity
		
	elif depth % 2 == 0:
		eval = -INF
		
		for child in self.children:
	
			child.alpha = alpha
			child.beta = beta
			var value = child.evaluate()
			
			if value > eval:
				eval = value
				best_child = child
			
				
			alpha = max(alpha, eval)
			if beta <= alpha:
				break
	else:
		eval = +INF
		for child in self.children:
			
			child.alpha = alpha
			child.beta = beta
			var value = child.evaluate()
			
			if value < eval:
				eval = value
				best_child = child
			
			beta = min(beta, eval)
			if beta <= alpha:
				break

	return eval
	
func print_eval():
	for i in range(self.depth):
		printraw("---")
	print(self.eval)
	if children != null:
		for child in self.children:
			child.print_eval()
		
