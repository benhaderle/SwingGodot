extends Area2D

@onready var collisionShape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body):
	SignalBus.room_area_entered.emit(collisionShape.global_position, collisionShape.shape.get_rect())
