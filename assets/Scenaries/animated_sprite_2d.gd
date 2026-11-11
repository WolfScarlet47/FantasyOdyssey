extends AnimatedSprite2D

const RAPIDEZ = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var x := Input.get_axis("ui_left", "ui_right")
	var y := Input.get_axis("ui_up", "ui_down")

	var direccion := Vector2(x, y).normalized()
	
	position += direccion * RAPIDEZ * delta;

	pass
