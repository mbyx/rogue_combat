@tool extends Camera2D
class_name FramedCamera

@onready var TILE_SIZE: Vector2 = UILayer.tile_set.tile_size

@export_group("Dependencies")
@export var FollowTarget: Node2D
@export var UILayer: TileMapLayer

@export_group("Attributes")
@export var DEADZONE_SIZE: Vector2:
	set(value):
		DEADZONE_SIZE = value
		queue_redraw()

@export var show_bounding_box: bool = true:
	set(value):
		show_bounding_box = value
		queue_redraw()

func _draw() -> void:
	# Draw the bounding box in the editor for debugging purposes.
	if Engine.is_editor_hint() and show_bounding_box:
		var deadzone_box = _get_deadzone_bounding_box()
		var relative_position = deadzone_box.position - position
		draw_rect(Rect2(relative_position, deadzone_box.size), Color.BLACK, false, 1)

func _get_deadzone_bounding_box() -> Rect2:
	# Center the deadzone around the camera's position in world space
	var deadzone_position = global_position - DEADZONE_SIZE / 2
	return Rect2(deadzone_position, DEADZONE_SIZE)

func _ready() -> void:
	# Start out with an integer multiple of tile size to prevent bugs.
	position = position.snapped(TILE_SIZE)

func _calculate_deadzone_direction(deadzone_box: Rect2, follow_position: Vector2) -> Vector2:
	var outside_left = int(follow_position.x < deadzone_box.position.x)
	var outside_right = int(follow_position.x >= deadzone_box.position.x + deadzone_box.size.x)
	var outside_up = int(follow_position.y < deadzone_box.position.y)
	var outside_down = int(follow_position.y >= deadzone_box.position.y + deadzone_box.size.y)
	
	return Vector2(outside_right - outside_left, outside_down - outside_up)

func _move_deadzone_with_follow_target(follow_position: Vector2) -> void:
	var deadzone_box = _get_deadzone_bounding_box()

	if not deadzone_box.has_point(follow_position):
		var direction = _calculate_deadzone_direction(deadzone_box, follow_position)
		if direction != Vector2.ZERO:
			var target_position = position + direction * TILE_SIZE
			position = _clamp_camera_within_limits(target_position)

func _process(delta: float) -> void:
	# As the follower uses a grid, it's actual position is different from it's grid position.
	var follow_position = UILayer.map_to_local(
		UILayer.local_to_map(FollowTarget.position)) - TILE_SIZE / 2
	_move_deadzone_with_follow_target(follow_position)


func _clamp_camera_within_limits(target_position: Vector2) -> Vector2:
	var clamped_x = clamp(target_position.x, limit_left, limit_right)
	var clamped_y = clamp(target_position.y, limit_top, limit_bottom)

	return Vector2(clamped_x, clamped_y)
