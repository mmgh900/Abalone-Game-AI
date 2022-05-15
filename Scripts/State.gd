extends Reference

class_name State

var board = []
var black_score = 0
var white_score = 0
var best_index = 0
var children = null
var depth = 0
var rng = RandomNumberGenerator.new()
var eval = -1
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

func findMinState():
	var minimum = INF
	for i in range(len(children)):
		var score = children[i].evaluate()
		if score <= minimum:
			minimum = score
			self.best_index = i
	return minimum

func findMaxState():
	var maximum = -INF
	for i in range(len(children)):
		var score = children[i].evaluate()
		if score >= maximum:
			maximum = score
			self.best_index = i
	return maximum

func evaluate():
	if children == null:
		var score = white_score - black_score
		rng.randomize()
		var rand_epslion = rng.randf()
		self.eval = score + rand_epslion
	elif depth % 2 == 0:
		self.eval = self.findMaxState()
	else:
		self.eval =  self.findMinState()
	return self.eval
	
	
func print_eval():
	for i in range(self.depth):
		printraw("---")
	print(self.eval)
	if children != null:
		for child in self.children:
			child.print_eval()
		
