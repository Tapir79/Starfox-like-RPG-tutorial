extends KinematicBody2D

export var ACCELERATION = 500
export var FRICTION = 500
export var MAX_SPEED = 100
export var ROLL_SPEED_MULTIPLIER = 1.1

enum {
	MOVE,
	ROLL,
	ATTACK,
	SHOOT
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
# PlayerStats is auto-load global singleton
var stats = PlayerStats

# replaces _ready() function s
onready var animationPlayer = $AnimationPlayer 
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox

func _ready():
	stats.connect("no_health",self,"queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

# Called every frame. 'delta' is the elapsed time since the previous frame.
# get's called when physics updates	
func _physics_process(delta):	
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		ROLL:
			roll_state(delta)
		SHOOT:
			pass
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move(velocity)
	
	if Input.is_action_pressed("roll"):
		state = ROLL
	
	if Input.is_action_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_state(delta):
	velocity = roll_vector * MAX_SPEED * ROLL_SPEED_MULTIPLIER
	animationState.travel("Roll")
	move(velocity)

func move(velocity):
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	state = MOVE
	
func attack_animation_finished():	
	state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invicibility(1)
	hurtbox.create_hit_effect()
