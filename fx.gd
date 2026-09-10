extends Node2D

var life := 0.22
var kind := "impact"
var direction := Vector2.RIGHT
var power := 1.0

func setup(k: String, d: Vector2 = Vector2.RIGHT, p: float = 1.0, duration: float = 0.22) -> void:
    kind = k
    direction = d.normalized() if d.length() > 0.01 else Vector2.RIGHT
    power = p
    life = duration
    z_index = 100
    queue_redraw()

func _process(delta: float) -> void:
    life -= delta
    if life <= 0.0:
        queue_free()
    else:
        queue_redraw()

func _draw() -> void:
    var a := clamp(life / 0.22, 0.0, 1.0)
    if kind == "launch":
        for i in range(6):
            var d := direction.rotated((i - 2.5) * 0.13)
            draw_line(-d * 8.0, -d * (34.0 + power * 10.0), Color(1,1,1,0.8*a), 3.0)
    elif kind == "impact":
        var r := 12.0 + (1.0-a) * (40.0 + power * 12.0)
        draw_arc(Vector2.ZERO, r, 0, TAU, 28, Color(1,1,1,0.9*a), 4.0)
        for i in range(8):
            var ang := TAU * i / 8.0
            var d := Vector2(cos(ang), sin(ang))
            draw_line(d*12.0, d*(30.0+power*10.0), Color(1.0,0.82,0.25,0.85*a), 4.0)
    elif kind == "trail":
        draw_line(Vector2.ZERO, -direction * (30.0 + power*10.0), Color(1,1,1,0.38*a), 4.0)
