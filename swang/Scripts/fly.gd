extends Node2D

@onready var startingPosition = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var lastPosition = position
	position = startingPosition + Vector2.RIGHT.rotated(Time.get_ticks_msec() * .005) * 40

func on_body_entered(body: Node2D) -> void:
	queue_free()
	pass
