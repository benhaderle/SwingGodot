class_name NPCController
extends Area2D

@export var dialogueLine : String

func _on_body_entered(body: Node2D) -> void:
	SignalBus.dialogue_entered.emit(dialogueLine, position - Vector2(0, $Sprite2D.region_rect.size.y * scale.y * .5))

func _on_body_exited(body: Node2D) -> void:
	SignalBus.dialogue_exited.emit()
