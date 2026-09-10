extends Node2D

func _ready() -> void:
    z_index = 1000
    queue_redraw()

func _draw() -> void:
    var y := 20.0

    # Movement
    _key(Vector2(22, y), "A", 42)
    _key(Vector2(68, y), "D", 42)
    _double_arrow(Vector2(132, y + 21))

    # Jump
    _key(Vector2(180, y), "SPACE", 82)
    _jump_icon(Vector2(284, y + 22))

    # Grab
    _key(Vector2(326, y), "J", 42)
    _grab_icon(Vector2(388, y + 22))

    # Throws: K + arrow icons only
    _key(Vector2(438, y), "K", 42)
    _arrow_key(Vector2(486, y), Vector2.LEFT)
    _throw_icon(Vector2(552, y + 22), Vector2.LEFT)

    _key(Vector2(610, y), "K", 42)
    _arrow_key(Vector2(658, y), Vector2.RIGHT)
    _throw_icon(Vector2(724, y + 22), Vector2.RIGHT)

    _key(Vector2(782, y), "K", 42)
    _arrow_key(Vector2(830, y), Vector2.DOWN)
    _slam_icon(Vector2(896, y + 22))

    # Rear throw
    _key(Vector2(954, y), "K", 42)
    _rear_icon(Vector2(1018, y + 22))

    # Reset at far right
    _key(Vector2(1080, y), "R", 42)
    _reset_icon(Vector2(1142, y + 22))

func _key(pos: Vector2, text: String, width: float) -> void:
    var rect := Rect2(pos, Vector2(width, 42))
    draw_rect(rect, Color(0.97, 0.98, 1.0, 0.94), true)
    draw_rect(rect, Color(0.10, 0.13, 0.18, 0.95), false, 3.0)

    var font := ThemeDB.fallback_font
    var size := 20 if text.length() <= 2 else 13
    var s := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
    draw_string(
        font,
        pos + Vector2((width - s.x) / 2.0, 27),
        text,
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        size,
        Color(0.08, 0.10, 0.14)
    )

func _arrow_key(pos: Vector2, dir: Vector2) -> void:
    _key(pos, "", 42)
    var c := pos + Vector2(21, 21)
    _arrow(c, dir, Color(0.08,0.10,0.14), 18)

func _arrow(c: Vector2, dir: Vector2, color: Color, length: float) -> void:
    var d := dir.normalized()
    var n := Vector2(-d.y, d.x)
    var tip := c + d * length * 0.55
    var back := c - d * length * 0.45
    draw_line(back, tip, color, 4.0)
    draw_colored_polygon(
        PackedVector2Array([
            tip,
            tip - d * 8 + n * 5,
            tip - d * 8 - n * 5
        ]),
        color
    )

func _double_arrow(c: Vector2) -> void:
    _arrow(c + Vector2(-8,0), Vector2.LEFT, Color(0.08,0.10,0.14), 18)
    _arrow(c + Vector2(8,0), Vector2.RIGHT, Color(0.08,0.10,0.14), 18)

func _jump_icon(c: Vector2) -> void:
    draw_arc(c + Vector2(0, 7), 16, PI, TAU, 18, Color(0.08,0.10,0.14), 3.5)
    draw_circle(c + Vector2(0,-10), 5, Color(0.30,0.55,0.92))

func _grab_icon(c: Vector2) -> void:
    draw_circle(c + Vector2(-7,0), 7, Color(0.30,0.55,0.92))
    draw_circle(c + Vector2(7,0), 7, Color(0.82,0.36,0.34))
    draw_line(c + Vector2(-2,-5), c + Vector2(2,5), Color(0.08,0.10,0.14), 2.5)

func _throw_icon(c: Vector2, dir: Vector2) -> void:
    var flip := -1.0 if dir.x < 0 else 1.0
    var pts := PackedVector2Array()
    for i in range(12):
        var t := float(i) / 11.0
        pts.append(c + Vector2(flip * (t * 38 - 19), -sin(t * PI) * 16))
    draw_polyline(pts, Color(0.92,0.20,0.16), 4.0)
    _arrow(pts[-1], (pts[-1] - pts[-2]).normalized(), Color(0.92,0.20,0.16), 13)

func _slam_icon(c: Vector2) -> void:
    _arrow(c + Vector2(0,-2), Vector2.DOWN, Color(0.92,0.20,0.16), 28)
    draw_line(c + Vector2(-15,17), c + Vector2(15,17), Color(0.08,0.10,0.14), 3.0)

func _rear_icon(c: Vector2) -> void:
    draw_circle(c + Vector2(7,0), 8, Color(0.82,0.36,0.34))
    draw_circle(c + Vector2(-8,0), 7, Color(0.30,0.55,0.92))
    draw_arc(c, 18, -0.25*PI, 1.25*PI, 20, Color(0.92,0.20,0.16), 3.0)

func _reset_icon(c: Vector2) -> void:
    draw_arc(c, 14, -0.25*PI, 1.5*PI, 20, Color(0.08,0.10,0.14), 3.5)
    var tip := c + Vector2(-13,-7)
    draw_colored_polygon(
        PackedVector2Array([
            tip,
            tip + Vector2(9,-1),
            tip + Vector2(3,8)
        ]),
        Color(0.08,0.10,0.14)
    )
