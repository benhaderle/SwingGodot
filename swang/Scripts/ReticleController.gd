extends Sprite2D

signal clicked_on_grapple_area(clickPosition : Vector2)
signal clicked_release_from_grapple_area

var overGrappleArea : bool
var emittedGrapple : bool

@export var highlightedColor : Color
@export var normalColor : Color
@export var highlightedScale : float
@export var normalScale : float
@export var pressedDownScale : float

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	overGrappleArea = false
	emittedGrapple = false

func _process(delta):
	position = get_viewport().get_camera_2d().get_global_mouse_position()
	
	if overGrappleArea:
		rotation = rotation + 1 * delta
	
	if Input.is_action_just_pressed("Grapple"):
		scale = Vector2(pressedDownScale, pressedDownScale)
		if overGrappleArea:
			emit_signal("clicked_on_grapple_area", global_position)
			emittedGrapple = true
	elif Input.is_action_just_released("Grapple"):
		if overGrappleArea:
			scale = Vector2(highlightedScale, highlightedScale)
		else:
			scale = Vector2(normalScale, normalScale)
			
		if emittedGrapple:
			emit_signal("clicked_release_from_grapple_area")
			emittedGrapple = false

func _on_mouse_entered_grapple_area():
	scale = Vector2(highlightedScale, highlightedScale)
	modulate = highlightedColor
	overGrappleArea = true

func _on_mouse_exited_grapple_area():
	scale = Vector2(normalScale, normalScale)
	modulate = normalColor
	overGrappleArea = false
