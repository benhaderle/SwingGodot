extends Node

@onready var playerBody = $PlayerBody
@onready var trail : Line2D = $TrailLine
@onready var debugLine : Line2D = $DebugLine
@onready var grapple = $Grapple
@onready var grappleLine = $GrappleLine

# gravity while free flying
@export var gravity : float
# gravity while grappled 
@export var grappleGravity : float 
# whether or not we are currently grappled
var grappled : bool
# whether or not the grapple is currently flying towards a target
var grappleFlying : bool
# how long the grapple line length is
var lineLength : float
# whether or not we are currently free flying.
# note that you can be grappled and free falling when the player's distance to a grapple point is less than the line length
var freeFlying : bool
# the magnitude of the current velocity when grappled
var grappledVel : float

func _on_ready():
	Utils.disableNode(grapple)

func _physics_process(delta):
	if grappled:
		var grappleToPlayer : Vector2 = (grapple.position - playerBody.position)
		
		if grappleToPlayer.length() >= lineLength:
			if freeFlying:
				grappledVel = playerBody.velocity.length()
				freeFlying = false
			
			var k = .001

			var distToLineLength = (grappleToPlayer.length() - lineLength)
			
			debugLine.points[0] = playerBody.position
			var normalizedGrappleToPlayer = grappleToPlayer.normalized()
			var ccw = Vector2(normalizedGrappleToPlayer.y, -normalizedGrappleToPlayer.x)
			var cw = Vector2(-normalizedGrappleToPlayer.y, normalizedGrappleToPlayer.x)
			
			var desiredVelocity
			if(cw.dot(playerBody.velocity) > ccw.dot(playerBody.velocity)):
				debugLine.points[1] = playerBody.position + cw * 100
				desiredVelocity = grappledVel * cw
			else:
				debugLine.points[1] = playerBody.position + ccw * 100
				desiredVelocity = grappledVel * ccw
#			
			playerBody.velocity = lerp(playerBody.velocity, desiredVelocity, delta)
			
			playerBody.velocity += distToLineLength * k * distToLineLength * normalizedGrappleToPlayer * delta
		else:
			freeFlying = true
			
		playerBody.velocity += Vector2(0,grappleGravity) * delta
	else:
		if playerBody.is_on_floor():
			playerBody.velocity = Vector2(0,0)
		else:
			playerBody.velocity += Vector2(0,gravity) * delta

	playerBody.move_and_collide(playerBody.velocity)

func _process(delta):
	if grapple.process_mode != PROCESS_MODE_DISABLED:
		if Input.is_action_pressed("Shorten"):
			lineLength -= 400 * delta
			lineLength = clampf(lineLength, 200, INF)
		
		Utils.enableNode(grappleLine)
		grappleLine.points[0] = playerBody.position
		grappleLine.points[1] = grapple.position
	else:
		Utils.disableNode(grappleLine)
		
	trail.add_point(playerBody.global_position)

func _on_clicked_release_from_grapple_area():
	move_grapple(grapple.position, playerBody)
	grappled = false

func _on_reticle_clicked_on_grapple_area(clickPosition):
	move_grapple(playerBody.position, clickPosition)

func move_grapple(startPosition : Vector2, target : Variant):
	if grappleFlying:
		grappleFlying = false
	
	await get_tree().physics_frame
	
	grapple.position = startPosition
	grappleFlying = true
	Utils.enableNode(grapple)
	
	var collision
	grapple.get_node("CollisionShape2D").disabled = true
	while grappleFlying:
		
		var direction : Vector2
		if target is Vector2:
			direction = (target - grapple.position).normalized()
		elif target is Node2D:
			direction = (target.position - grapple.position).normalized()
		collision = grapple.move_and_collide(5000 * direction * get_physics_process_delta_time())
		
		if collision != null:
			grappleFlying = false
			grapple.position = collision.get_position()
			
			var collider : CollisionObject2D = collision.get_collider()
			if collider.get_collision_layer_value(2):
				Utils.disableNode(grapple)
			elif collider.get_collision_layer_value(1):
				grappled = true
				freeFlying = false
				lineLength = (playerBody.position - grapple.position).length()
				grappledVel = playerBody.velocity.length()
			
		await get_tree().physics_frame
		
		grapple.get_node("CollisionShape2D").disabled = false
	
	print("done flying")

