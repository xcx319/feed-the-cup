extends Node2D
# RemotePlayer.gd
# 远程玩家的本地代理节点
# 接收服务器转发的状态并更新显示
#
# 挂载到一个简单的 Node2D 上，包含：
# - Sprite 或 AnimatedSprite（显示角色）
# - Label（显示名字）
# - ProgressBar（显示压力值）

var player_id: int = 0
var player_name: String = ""

# 平滑插值
var _target_pos: Vector2 = Vector2.ZERO
var _cur_pressure: int = 0
var _cur_pressure_max: int = 100

onready var NameLabel: Label = $NameLabel
onready var PressureBar: ProgressBar = $PressureBar

const LERP_SPEED: float = 10.0

func _ready():
	var _c = OnlineNetwork.connect("on_player_state", self, "_on_player_state")
	var _c2 = OnlineNetwork.connect("on_player_left", self, "_on_player_left")

func _process(delta):
	# 平滑移动到目标位置
	position = position.linear_interpolate(_target_pos, LERP_SPEED * delta)

func init(pid: int, pname: String):
	player_id = pid
	player_name = pname
	if NameLabel:
		NameLabel.text = pname

func _on_player_state(pid: int, pos: Vector2, pressure: int, hold_item: String, face: int, state: int):
	if pid != player_id:
		return
	_target_pos = pos
	_cur_pressure = pressure
	if PressureBar:
		PressureBar.value = float(pressure) / float(max(_cur_pressure_max, 1)) * 100.0

func _on_player_left(pid: int, _pname: String):
	if pid == player_id:
		queue_free()
