extends Camera2D

# TODO: Modify code to turn into a dead zone camera.
# While there would be separate controls to move the camera,
# you can also move it with the cursor. There will be a deadzone around the
# screen where the cursor moves without moving the camera. After that zone,
# the camera will move with the cursor until the cursor goes into the deadzone
# again. Additionally the camera can move separately but only upto the limit
# of the boundary of the level itself.
# Finally there needs to be a button (Right Joystick Press) that moves back
# to the center of the cursor.
# Left Joystick Press to move back cursor to 0,0 of the map

@export var UILayer: TileMapLayer
@onready var TILE_SIZE: Vector2i = UILayer.tile_set.tile_size
const MOVEMENT_SPEED: float = 250

func handle_input(delta: float) -> void:
	var dir_x = Input.get_action_strength("Camera_Right") - Input.get_action_strength("Camera_Left")
	var dir_y = Input.get_action_strength("Camera_Down") - Input.get_action_strength("Camera_Up")

	var target_position = position + Vector2(dir_x * TILE_SIZE.x, dir_y * TILE_SIZE.y)

	if position != target_position:
		position = position.move_toward(target_position, delta * MOVEMENT_SPEED)

func _ready() -> void:
	position = position.snapped(TILE_SIZE)

func _process(delta: float) -> void:
	handle_input(delta)
