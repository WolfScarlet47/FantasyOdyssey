extends Area2D

@export var target_path: NodePath = NodePath("../Character")
@export var speed: float = 90.0

const MAP_SIZE: Vector2 = Vector2(2160.0, 1440.0)
const EDGE_MARGIN: float = 32.0

var target: Node2D


func _ready() -> void:
	add_to_group("enemies")
	target = get_node_or_null(target_path) as Node2D
	if target == null:
		push_warning("EnemyChase: no se encontró el objetivo en target_path.")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target) or not target.visible:
		return

	var direction := global_position.direction_to(target.global_position)
	if direction.is_zero_approx():
		return

	global_position += direction * speed * delta
	global_position.x = clampf(global_position.x, EDGE_MARGIN, MAP_SIZE.x - EDGE_MARGIN)
	global_position.y = clampf(global_position.y, EDGE_MARGIN, MAP_SIZE.y - EDGE_MARGIN)
