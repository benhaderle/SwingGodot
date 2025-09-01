extends Camera2D

func _ready() -> void:
	%PlayerController.grappled.connect(on_grappled)
	SignalBus.room_area_entered.connect(on_room_area_entered)

func on_room_area_entered(roomCenter : Vector2, roomBounds : Rect2):
	global_position = roomCenter
	zoom = Vector2.ONE * minf(get_viewport_rect().size.x / roomBounds.size.x, get_viewport_rect().size.y / roomBounds.size.y)
	pass

func on_grappled() -> void:
	if is_current():
		screenshake(.5, 16, .35)

func screenshake(amplitude: float, frequency: float, length: float) -> void:
	var pos = transform.origin
	var f = 1 / frequency
	var fTimer = -1
	
	while length > 0:
		if fTimer < 0:
			transform.origin = pos + Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))
			fTimer = f
		
		fTimer -= get_process_delta_time()
		length -= get_process_delta_time()
		await get_tree().process_frame
	
