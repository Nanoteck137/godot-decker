extends Sprite2D

func _ready():
	pass

func _process(delta):
	rotate((PI * 2) * delta)
