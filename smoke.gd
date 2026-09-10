extends Node2D

var life := 0.72
var max_life := 0.72
var drift := Vector2.ZERO
var scale_base := 1.0

func setup(direction: Vector2, power: float) -> void:
    var d := direction.normalized() if direction.length() > 0.01 else Vector2.RIGHT
    drift = -d * randf_range(28.0, 55.0) + Vector2(0, randf_range(-22.0, -8.0))
    scale_base = 0.9 + power * 0.22
    rotation = randf_range(-0.4, 0.4)
    z_index = 30
    queue_redraw()

func _process(delta: float) -> void:
    life -= delta
    position += drift * delta
    drift *= 0.985
    if life <= 0.0:
        queue_free()
    else:
        queue_redraw()

func _draw() -> void:
    var t := 1.0 - life / max_life
    var fade := pow(max(0.0, 1.0 - t), 1.35)
    var grow := 0.75 + t * 1.35
    var r := 13.0 * scale_base * grow

    # Strong enough to be clearly visible on the blue sky.
    draw_circle(Vector2(-7, 2), r, Color(0.70,0.72,0.74,0.62*fade))
    draw_circle(Vector2(7, 0), r*0.82, Color(0.82,0.83,0.84,0.58*fade))
    draw_circle(Vector2(0,-9), r*0.70, Color(0.94,0.94,0.94,0.65*fade))
