extends Area2D

export var Direction: Vector2

func _ready():
	pass

func _on_Area2D_body_entered(body):
	if body.has_method("_PlayerNode"):
		if not body.GearList.has(self):
			body.GearList.append(self)


func _on_Area2D_body_exited(body):
	if body.has_method("_PlayerNode"):
		if body.GearList.has(self):
			body.GearList.erase(self)

func _on_Area2D_area_entered(area):
	if area.has_method("_item_move"):
		if not area.GearList.has(self):
			area.GearList.append(self)
			area._item_move()

func _on_Area2D_area_exited(area):
	if area.has_method("_item_move"):
		if area.GearList.has(self):
			area.GearList.erase(self)
			area._item_move()
