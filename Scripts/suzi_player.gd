extends CharacterBody3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensivity:=0.25

var _footstep_timer := 0.0
var _step_interval := 0.4  # tune this for faster/slower footsteps


@export_group("Movement")
@export var move_speed=8.0
@export var sprint_multiplier = 1.5
@export var acceleration:=20.0
@export var rotation_speed := 12.0
@export var jump_impluse :=12.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
#make character accelerate down
var _gravity := -30.0

@onready var _camera_pivot: Node3D= %CameraPivot
@onready var _camera: Camera3D=%Camera3D
@onready var _skin: SuziSkin =%SuziSkin

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() ==Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction=event.screen_relative * mouse_sensivity

func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x +=_camera_input_direction.y*delta
	#clamping the camera between -30 degree and 60 degree
	_camera_pivot.rotation.x=clamp(_camera_pivot.rotation.x,-PI/6.0,PI/3.0)
	_camera_pivot.rotation.y +=_camera_input_direction.x*delta
	
	_camera_input_direction=Vector2.ZERO
	
	var raw_input :=Input.get_vector("move_left","move_right","move_up","move_down")
	var forward:=_camera.global_basis.z
	var right :=_camera.global_basis.x
	
	var move_direction := forward*raw_input.y + right*raw_input.x
	move_direction.y=0.0
	move_direction=move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y=0.0
	var is_sprinting := Input.is_action_pressed("sprint")
	var speed: float = move_speed * (sprint_multiplier if is_sprinting else 1.0)
	velocity = velocity.move_toward(move_direction * speed, acceleration * delta)


	velocity.y=y_velocity + _gravity*delta
	
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	
	if is_starting_jump:
		velocity.y +=jump_impluse
	
	move_and_slide()
	
	if move_direction.length() >0.2:
		_last_movement_direction=move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction,Vector3.UP)
	_skin.global_rotation.y=lerp_angle(_skin.rotation.y,target_angle,rotation_speed*delta)
	
	
	if is_starting_jump:
		_skin.jump()
		$jump.play()
	elif not is_on_floor() and velocity.y<0:
		_skin.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed >0.0:
			_skin.move()
			
			# Footstep sound logic
			_footstep_timer -= delta
			if _footstep_timer <= 0.0:
				$"Footsteps sound".play()
				_footstep_timer = _step_interval / (sprint_multiplier if is_sprinting else 1.0)
				
				
		else:
			_skin.idle()
			_footstep_timer = 0.0  # reset to prevent immediate sound when starting again


			

	
	
	
