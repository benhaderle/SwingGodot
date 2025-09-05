@tool
extends Polygon2D

@export var cornerCollider : PackedScene

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		$StaticBody2D/CollisionPolygon2D.polygon = polygon
		$LightOccluder2D.occluder.polygon = polygon

func _ready() -> void:
	$LightOccluder2D.show()
	$StaticBody2D.mouse_entered.connect(on_mouse_entered)
	$StaticBody2D.mouse_exited.connect(on_mouse_exited)
	
	for p in polygon:
		var c = cornerCollider.instantiate()
		c.global_position = p
		add_child(c)
	
func on_mouse_entered():
	SignalBus.mouse_entered_grapple_area.emit()
	
func on_mouse_exited():
	SignalBus.mouse_exited_grapple_area.emit()
