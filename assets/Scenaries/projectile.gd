extends Area2D

@export var speed: float = 500.0
@export var damage: float = 10.0
@export var max_distance: float = 250.0

var direction: Vector2 = Vector2.ZERO
var distance_travelled: float = 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)

	# Dibuja una pequeña bola azul como imagen provisional.
	var points := PackedVector2Array()
	for i in range(16):
		var angle := TAU * float(i) / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * 6.0)
	$Visual.polygon = points
	$Visual.color = Color(0.2, 0.6, 1.0, 1.0)


# Fija la dirección para que el proyectil viaje en línea recta.
func launch(flight_direction: Vector2) -> void:
	direction = flight_direction.normalized()


func _process(delta: float) -> void:
	if direction.is_zero_approx():
		return

	var movement := direction * speed * delta
	global_position += movement
	distance_travelled += movement.length()

	if distance_travelled >= max_distance:
		queue_free()


# Al tocar un enemigo, le quita vida y desaparece.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
