extends Sprite2D

func _ready():
	ghosting()
# Called when the node enters the scene tree for the first time.
func set_property(tx_pos,tx_scale):
	position = tx_pos
	scale = tx_scale
	
func ghosting():
	if visible:
		var tween_fade = get_tree().create_tween()
		tween_fade.tween_property(self,"self_modulate",Color(1, 1, 1, 0),0.30)
		await tween_fade.finished
		queue_free()
