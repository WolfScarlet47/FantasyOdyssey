extends AnimatedSprite2D

const RAPIDEZ: float = 200.0
const TAMANO_MAPA: Vector2 = Vector2(2160.0, 1440.0)
const MARGEN_LIMITE: float = 32.0

func _process(delta: float) -> void:
	# Leer las entradas de movimiento configuradas por defecto en Godot.
	var x: float = Input.get_axis("ui_left", "ui_right")
	var y: float = Input.get_axis("ui_up", "ui_down")

	# Normalizar evita que el movimiento diagonal sea más rápido.
	var direccion: Vector2 = Vector2(x, y).normalized()
	position += direccion * RAPIDEZ * delta

	# Mantener a Zuo dentro de los límites del mapa.
	position.x = clampf(position.x, MARGEN_LIMITE, TAMANO_MAPA.x - MARGEN_LIMITE)
	position.y = clampf(position.y, MARGEN_LIMITE, TAMANO_MAPA.y - MARGEN_LIMITE)
