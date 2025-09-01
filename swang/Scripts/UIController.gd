extends CanvasLayer

@onready var dialogueLabel = $DialogueLabel

@export var maxDialogueLabelWidth : float = 600

var padding : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.dialogue_entered.connect(on_dialogue_entered)
	SignalBus.dialogue_exited.connect(on_dialogue_exited)
	
	dialogueLabel.hide()
	var stylebox : StyleBox = dialogueLabel.get_theme_stylebox("normal")
	padding = Vector2(stylebox.content_margin_left + stylebox.content_margin_right, stylebox.content_margin_bottom + stylebox.content_margin_top)
	pass

func on_dialogue_entered(dialogueText, dialoguePosition):
	dialogueLabel.show()
	dialogueLabel.text = dialogueText
	dialogueLabel.set_size(Vector2(maxDialogueLabelWidth, dialogueLabel.size.y) + padding)
	#idk why setting size to be the content width + padding doesn't work, but adding 8 here seems to stabilize things
	dialogueLabel.set_size(Vector2(dialogueLabel.get_content_width()+ 8, dialogueLabel.get_content_height()) + padding)
	
	var viewport = get_viewport()
	var visibleRect = viewport.get_visible_rect()
	var camera = viewport.get_camera_2d()
	
	var viewportSizeInWorldUnits = visibleRect.size / camera.zoom
	var topLeftCameraPos = camera.position - viewportSizeInWorldUnits * .5
	dialoguePosition = (dialoguePosition - topLeftCameraPos) / viewportSizeInWorldUnits * visibleRect.size
	
	dialogueLabel.position = dialoguePosition - Vector2(dialogueLabel.size.x * .5, dialogueLabel.size.y + 10)
	
	pass

func on_dialogue_exited():
	dialogueLabel.hide()
	pass
