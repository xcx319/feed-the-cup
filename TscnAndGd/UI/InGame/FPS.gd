extends Label

func _ready():
	set_physics_process(true)
func _physics_process(_delta):
	var fps = Engine.get_frames_per_second()
	self.text = "FPS:" + str(fps)
