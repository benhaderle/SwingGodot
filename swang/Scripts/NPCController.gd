class_name NPCController
extends Area2D

@onready var label = $Label

@export var dialogueLine : String

func _ready() -> void:
	label.hide()

func _on_body_entered(body: Node2D) -> void:
	label.text = dialogueLine
	label.show()

func _on_body_exited(body: Node2D) -> void:
	label.hide()
