extends Node2D

var kind := "impact"
var life := 0.25
var total_life := 0.25
var direction := Vector2.RIGHT
var power := 1.0

func setup(effect_kind: String, effect_direction: Vector2 = Vector2.RIGHT, effect_power: float = 1.0, duration: float = 0.25) -> void:
    kind = effect_kind
    direction = effect_direction.normalized() if effect_direction.length() > 0.01 else Vector2.RIGHT
    power = effect_power
    life = duration
    total_life = duration
    z_index = 50
    queue_redraw()

func _process(delta: float) -> void:
    life -= delta
    if life <= 0.0:
        queue_free()
        return
    queue_redraw()

func _draw() -> void:
    var t := clamp(1.0 - life / total_life, 0.0, 1.0)
    var fade := 1.0 - t

    match kind:
        "launch":
            # Short white/yellow burst pointing opposite the throw direction.
            var back := -direction
            for i in range(6):
                var spread := (float(i) - 2.5) * 0.16
                var d := direction.rotated(spread)
                var start := -d * (8.0 + i * 2.0)
                var end := -d * (30.0 + 7.0 * power) * (0.6 + 0.4 * fade)
                draw_line(start, end, Color(1.0, 1.0, 1.0, 0.80 * fade), 3.0)
            draw_circle(Vector2.ZERO, 10.0 * (1.0 + t), Color(1.0, 0.88, 0.35, 0.40 * fade))

        "trail":
            var radius := 18.0 * (0.9 + 0.25 * t)
            draw_circle(Vector2(0, -15), radius, Color(1.0, 1.0, 1.0, 0.12 * fade))
            draw_line(Vector2.ZERO, -direction * (24.0 + power * 10.0), Color(1.0, 1.0, 1.0, 0.35 * fade), 4.0)

        "impact":
            var r := 12.0 + t * (35.0 + 15.0 * power)
            draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(1.0, 1.0, 1.0, 0.9 * fade), 4.0)
            for i in range(10):
                var a := TAU * float(i) / 10.0
                var d := Vector2(cos(a), sin(a))
                var inner := d * (10.0 + t * 12.0)
                var outer := d * (28.0 + power * 14.0 + t * 24.0)
                draw_line(inner, outer, Color(1.0, 0.86, 0.30, 0.9 * fade), 4.0)
            # Dust puffs near the ground.
            draw_circle(Vector2(-20.0 - 18.0 * t, 4.0), 8.0 * fade, Color(0.88, 0.82, 0.68, 0.55 * fade))
            draw_circle(Vector2(20.0 + 18.0 * t, 4.0), 8.0 * fade, Color(0.88, 0.82, 0.68, 0.55 * fade))

        "slam":
            var r := 10.0 + t * (45.0 + 18.0 * power)
            draw_arc(Vector2.ZERO, r, PI, TAU, 28, Color(1.0, 1.0, 1.0, 0.95 * fade), 5.0)
            for i in range(8):
                var x := -42.0 + i * 12.0
                draw_line(Vector2(x * 0.45, 0), Vector2(x, -18.0 - 22.0 * power * fade), Color(1.0, 0.72, 0.22, 0.85 * fade), 4.0)
