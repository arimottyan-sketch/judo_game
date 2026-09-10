extends Node2D

var life := 0.22
var total_life := 0.22
var kind := "impact"
var direction := Vector2.RIGHT
var power := 1.0
var drift := Vector2.ZERO
var smoke_seed := 0.0

func setup(k: String, d: Vector2 = Vector2.RIGHT, p: float = 1.0, duration: float = 0.22) -> void:
    kind = k
    direction = d.normalized() if d.length() > 0.01 else Vector2.RIGHT
    power = p
    life = duration
    total_life = duration
    z_index = 100
    smoke_seed = randf_range(-1000.0, 1000.0)

    if kind == "smoke":
        # Smoke drifts slightly upward and opposite the throw direction.
        drift = -direction * randf_range(18.0, 42.0) + Vector2(0.0, randf_range(-28.0, -12.0))

    queue_redraw()

func _process(delta: float) -> void:
    life -= delta

    if kind == "smoke":
        position += drift * delta
        drift *= 0.985

    if life <= 0.0:
        queue_free()
    else:
        queue_redraw()

func _draw() -> void:
    var t := clamp(1.0 - life / total_life, 0.0, 1.0)
    var fade := 1.0 - t

    match kind:
        "launch":
            for i in range(6):
                var d := direction.rotated((float(i) - 2.5) * 0.13)
                draw_line(
                    -d * 8.0,
                    -d * (34.0 + power * 10.0),
                    Color(1.0, 1.0, 1.0, 0.82 * fade),
                    3.0
                )

        "trail":
            draw_line(
                Vector2.ZERO,
                -direction * (30.0 + power * 10.0),
                Color(1.0, 1.0, 1.0, 0.34 * fade),
                4.0
            )

        "smoke":
            # Three soft-ish overlapping puffs.
            var base_r := (7.0 + power * 2.2) * (0.75 + t * 1.25)
            var alpha := 0.30 * fade
            draw_circle(Vector2(-4, 1), base_r, Color(0.92, 0.92, 0.92, alpha))
            draw_circle(Vector2(4, -2), base_r * 0.82, Color(0.86, 0.86, 0.86, alpha * 0.9))
            draw_circle(Vector2(0, -7), base_r * 0.68, Color(1.0, 1.0, 1.0, alpha * 0.8))

        "impact":
            var r := 12.0 + t * (40.0 + power * 12.0)
            draw_arc(
                Vector2.ZERO,
                r,
                0,
                TAU,
                28,
                Color(1.0, 1.0, 1.0, 0.90 * fade),
                4.0
            )
            for i in range(8):
                var ang := TAU * float(i) / 8.0
                var d := Vector2(cos(ang), sin(ang))
                draw_line(
                    d * 12.0,
                    d * (30.0 + power * 10.0),
                    Color(1.0, 0.82, 0.25, 0.85 * fade),
                    4.0
                )

            # Ground dust at impact.
            draw_circle(Vector2(-18.0 - 16.0 * t, 4.0), 7.0 * fade, Color(0.82, 0.78, 0.68, 0.40 * fade))
            draw_circle(Vector2(18.0 + 16.0 * t, 4.0), 7.0 * fade, Color(0.82, 0.78, 0.68, 0.40 * fade))
