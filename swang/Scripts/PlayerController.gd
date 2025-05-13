extends Node

@onready var playerBody = $PlayerBody
@onready var trail : Line2D = $TrailLine
@onready var debugLine : Line2D = $DebugLine
@onready var grapple = $Grapple
@onready var grappleLine = $GrappleLine
@onready var groundCast = $PlayerBody/GroundCast

## how much lateral acceleration will be added to the player's velocity while in the air
@export var airLateralAcceleration: float = 2
## how much downward acceleration will be added to the player's velocity while in the air
@export var airDownwardAcceleration: float = 5
## the lateral component of a jump impulse from the ground
@export var groundLateralMovementSpeed : float = 10
## the upwards component of a jump impulse from the ground
@export var groundUpwardsMovementSpeed : float = 10
## gravity while free flying
@export var gravity : float
## gravity while grappled 
@export var grappleGravity : float 
## how powerful the spring of the grapple line is
@export var springConstant : float = .001
## how fast the grapple line will shorten 
@export var shortenSpeed : float = 400
## the minimum line length
@export var minLineLength : float = 200
## how fast the grapple extends or retracts from a grapple point
@export var grappleFlyingSpeed : float = 5000
## the bounciness of the player when hitting a wall
@export var bounceFactor : float = .5
## the threshold of velocity squared at which the player will stop moving if grounded
@export var stopVelocityThreshold : float = 10
## the maximum angle counted as a floor in radians 
@export var maxFloorAngle : float = .8
## whether or not we are currently grappled
var grappled : bool
## whether or not the grapple is currently flying towards a target
var grappleFlying : bool
## how long the grapple line length is
var lineLength : float
## whether or not we are stopped on the ground rn
var grounded : bool 
var groundNormal : Vector2

func _on_ready():
	Utils.disableNode(grapple)

func _physics_process(delta):
	debugLine.points[0] = playerBody.position
	if grappled:
		# add the grapple gravity
		playerBody.velocity += Vector2(0, grappleGravity) * delta
		
		var grappleToPlayer : Vector2 = (grapple.position - playerBody.position)
		var normalizedGrappleToPlayer = grappleToPlayer.normalized()
		
		# if the player is further from the grapple point than the line is long (ie they need to be pulled back in)
		if grappleToPlayer.length() >= lineLength:
			# the clockwise direction around the grapple point
			var cw = Vector2(-normalizedGrappleToPlayer.y, normalizedGrappleToPlayer.x)
			# the counter clockwise direction around the velocity
			var ccw = Vector2(normalizedGrappleToPlayer.y, -normalizedGrappleToPlayer.x)
			
			# desired velocity is the velocity we'd have if the grapple line was inelastic without considering gravity
			var desiredDirection
			# figure out which direction around the grapple point we're traveling in and then use the grappledVel to set the magnitude
			if(cw.dot(playerBody.velocity) > ccw.dot(playerBody.velocity)):
				desiredDirection = cw
			else:
				desiredDirection = ccw
#			
			# ease the current velocity towards the desired direction
			playerBody.velocity = playerBody.velocity.length() * lerp(playerBody.velocity.normalized(), desiredDirection.normalized(), delta)
			
			# how far the player is from being in the place they should be
			var distToLineLength = (grappleToPlayer.length() - lineLength)
			# pull the player towards the grapple point with strength exponentially relative to the how far from the line length they are
			playerBody.velocity += distToLineLength * distToLineLength * springConstant * normalizedGrappleToPlayer * delta
		else:
			addAirMovement(delta)
	# if we're not grappled
	else:
		# if we're grounded, we can do ground movement
		if grounded:
			if not Input.is_action_pressed("Down"):
				# if we're only pressing one of the lateral buttons, initiate a lateral jump
				if Input.is_action_pressed("Right") and not Input.is_action_pressed("Left"):
					playerBody.velocity = Vector2(0, groundUpwardsMovementSpeed) + -groundNormal.orthogonal() * groundLateralMovementSpeed
				elif Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
					playerBody.velocity = Vector2(0, groundUpwardsMovementSpeed) + groundNormal.orthogonal() * groundLateralMovementSpeed
		else:
			playerBody.velocity += Vector2(0, gravity) * delta
			addAirMovement(delta)
	
	var collision = playerBody.move_and_collide(playerBody.velocity)
	# handle the bounce off walls and grounded-ness
	if collision:
		# TODO: make the bounceFactor dependent on the surface we're bouncing on
		playerBody.velocity = playerBody.velocity.bounce(collision.get_normal()) * bounceFactor
		
		# if our velocity is less than the stop threshold and we're on a floor, stop the player
		if playerBody.velocity.length_squared() < stopVelocityThreshold and collision.get_angle() < maxFloorAngle:
			playerBody.velocity = Vector2(0, 0)
			grounded = true
			groundNormal = collision.get_normal()
		else:
			grounded = false
	# if there was no collision, but we're currently grounded, check to make sure we're still grounded
	elif grounded:
		groundCast.force_shapecast_update()
		if !groundCast.collision_result:
			grounded = false

func addAirMovement(delta):
	if Input.is_action_pressed("Down"):
		playerBody.velocity += Vector2(0, airDownwardAcceleration) * delta
		
	if Input.is_action_pressed("Right") and not Input.is_action_pressed("Left"):
		playerBody.velocity += Vector2(airLateralAcceleration, 0) * delta
	elif Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
		playerBody.velocity += Vector2(-airLateralAcceleration, 0) * delta

func _process(delta):
	# while the grapple is still active on the screen
	# this check is inclusive of both when grappled is true but also when the grapple is extending or retracting
	if grapple.process_mode != PROCESS_MODE_DISABLED:
		# make sure the line node is enabled
		Utils.enableNode(grappleLine)
		
		# shorten the line
		lineLength -= shortenSpeed * delta
		lineLength = clampf(lineLength, minLineLength, INF)
			
		# update the points
		grappleLine.points[0] = playerBody.position
		grappleLine.points[1] = grapple.position
	else:
		Utils.disableNode(grappleLine)
	
	# update the trail
	trail.add_point(playerBody.global_position)

# if we're no longer holding the grapple input, move the grapple back to the player
func _on_clicked_release_from_grapple_area():
	move_grapple(grapple.position, playerBody)
	grappled = false

# if we clicked on a grapple area, move the grapple towards the clicked point
func _on_reticle_clicked_on_grapple_area(clickPosition):
	move_grapple(playerBody.position, clickPosition)

## coroutine that moves the grapple towards the provided target. runs on the physics loop
func move_grapple(startPosition : Vector2, target : Variant):
	# reset grappleFlying
	grappleFlying = false
	
	# wait for one frame so we can stop any other occurences of this routine
	await get_tree().physics_frame
	
	# grappleFlying is basically the semafor for this routine
	grappleFlying = true
	
	# set the initial grapple position and enable the grapple node
	Utils.enableNode(grapple)
	grapple.position = startPosition
	
	# disable collision shape for one frame so we can start to fly
	grapple.get_node("CollisionShape2D").disabled = true
	
	while grappleFlying:
		# getting the direction to fly in is different depending on what target we were given
		var direction : Vector2
		# if the given target is a position vector
		if target is Vector2:
			direction = (target - grapple.position).normalized()
		# if the given target is another node
		elif target is Node2D:
			direction = (target.position - grapple.position).normalized()
		
		# move the grapple and record any collision
		var collision : KinematicCollision2D = grapple.move_and_collide(grappleFlyingSpeed * direction * get_physics_process_delta_time())
		
		# if there was a collision, it's time to do some stuff
		if collision != null:
			# no matter what we hit, set grappleFlying to false so that this routine will end
			grappleFlying = false
			grapple.position = collision.get_position()
			
			var collider : CollisionObject2D = collision.get_collider()
			# layer 2 is the player layer
			if collider.get_collision_layer_value(2):
				Utils.disableNode(grapple)
			# layer 1 is any grapple-able surface
			elif collider.get_collision_layer_value(1):
				# set up everything to be free flying
				grappled = true
				lineLength = (playerBody.position - grapple.position).length()
				
		# wait for another frame before continuing to fly
		await get_tree().physics_frame
		
		# enable the collision shape after one frame of movement 
		grapple.get_node("CollisionShape2D").disabled = false
