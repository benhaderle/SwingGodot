@tool
extends Polygon2D

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		$StaticBody2D/CollisionPolygon2D.polygon = polygon
		$LightOccluder2D.occluder.polygon = polygon
