extends Camera2D

var initialized = false
var nextRoomCenter : Vector2
var nextRoomRect : Rect2

func _ready() -> void:
	%PlayerController.grappled.connect(on_grappled)
	SignalBus.room_area_entered.connect(on_room_area_entered)
	SignalBus.room_area_exited.connect(on_room_area_exited)

func on_room_area_entered(roomCenter : Vector2, roomBounds : Rect2):
	nextRoomCenter = roomCenter
	nextRoomRect = roomBounds
	
	if !initialized:
		initialized = true
		set_camera_to_next_room()

func on_room_area_exited(roomCenter : Vector2):
	if(roomCenter == nextRoomCenter):
		return
	
	set_camera_to_next_room()

func set_camera_to_next_room():
	global_position = nextRoomCenter
	zoom = Vector2.ONE * minf(get_viewport_rect().size.x / nextRoomRect.size.x, get_viewport_rect().size.y / nextRoomRect.size.y)
	

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
	
