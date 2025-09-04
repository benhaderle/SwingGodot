extends Polygon2D

var isVisible : bool

func _enter_tree() -> void:
	$Area2D/CollisionPolygon2D.polygon = polygon
	$Area2D.mouse_entered.connect(on_mouse_entered)
	$Area2D.mouse_exited.connect(on_mouse_exited)
	$Area2D.body_entered.connect(on_body_entered)
	
func _exit_tree() -> void:
	$Area2D.mouse_entered.disconnect(on_mouse_entered)
	$Area2D.mouse_exited.disconnect(on_mouse_exited)
	$Area2D.body_entered.disconnect(on_body_entered)	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isVisible = true
	
func on_mouse_entered():
	SignalBus.mouse_entered_grapple_area.emit()
	
func on_mouse_exited():
	SignalBus.mouse_exited_grapple_area.emit()

func on_body_entered(body: Node2D):
	if isVisible:
		isVisible = false
		fade()

func fade():
	while color.a > 0:
		color.a -= get_process_delta_time()
		await get_tree().process_frame
	
	queue_free()
