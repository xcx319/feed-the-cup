extends Node

export var Name: String
export var Num: int
export var Ratio: int
export (Array, int) var ints = [1, 2, 3]
export (Array, int, "Red", "Green", "Blue") var enums = [2, 1, 0]
export (Array, Array, float) var two_dimensional = [[1, 2], [3, 4]]
export var strings = PoolStringArray()
export (int, "Warrior", "Magician", "Thief") var character_class
export (String, "Rebecca", "Mary", "Leah") var character_name

export (String, FILE) var f

export (String, DIR) var f1

export (String, FILE, "*.txt") var f2

class Father:
	var a
	var b
	func _init(_a, _b):
		a = _a
		b = _b
		pass

class Child:
	extends Father
	func _init(_a, _b).(_a, _b):
		pass
func _ready():
	var _child = Child.new("aa", "bb")
