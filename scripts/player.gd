extends CharacterBody2D

# Constants
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const JUMP_MAX = 2
const PUSH_FORCE = 100.0
const WALL_JUMP_PUSHBACK = 600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_count = 0

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _physics_process(delta):
	# Add the gravity. If on the floor, reset jump count to 0
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_count = 0

	# Handle double jump
	if Input.is_action_just_pressed("jump") and jump_count < JUMP_MAX:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	elif Input.is_action_just_pressed("jump") and is_on_wall():
		if Input.is_action_pressed("move_right"):
			velocity.y = JUMP_VELOCITY
			velocity.x = -WALL_JUMP_PUSHBACK
		if Input.is_action_pressed("move_left"):
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSHBACK

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip sprite based on the direction of movement
	if direction > 0:
		sprite.scale.x = 0.25
	elif  direction < 0: 
		sprite.scale.x = -0.25
		
	# Play animations based on player actions
	if is_on_floor():	
		if Input.is_action_just_pressed("attack"):
			animation_player.play("attack")
		if animation_player.current_animation != "attack":
			if direction == 0: 
				animation_player.play("idle")
			else:
				animation_player.play("run")
	else:
		if jump_count == 2:
			animation_player.play("double_jump")
		else:
			animation_player.play("jump")
		
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-1.0 * c.get_normal() * PUSH_FORCE)


func _on_weapon_area_2d_body_entered(body):
	if body.is_in_group("Enemy"):
		print("hit enemy")
		body.queue_free()

