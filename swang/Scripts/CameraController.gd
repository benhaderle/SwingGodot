extends Camera2D

func _ready() -> void:
	%PlayerController.grappled.connect(on_grappled)

func _on_area_2d_body_entered(body: Node2D) -> void:
	make_current()

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
	
