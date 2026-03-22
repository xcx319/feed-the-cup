extends TextureProgress

var _List: Array = [1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000, 5000000, 10000000, 20000000, 50000000]
var _Money: int
var _EGGCOIN: int
func _ready():
	set_process(false)

func call_init(_Coin: int):
	_Money = _Coin



func _EggCoin_Add():
	_EGGCOIN += 1
	get_parent().get_parent().get_parent().get_node("EggCoin").text = str(_EGGCOIN)
