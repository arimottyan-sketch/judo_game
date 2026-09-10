extends Control

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_preset(Control.PRESET_FULL_RECT)
    queue_redraw()

func _draw() -> void:
    # Compact top-left tutorial strip.
    var x := 24.0
    var y := 22.0

    _draw_key(Vector2(x, y), "A", Vector2(42, 42))
    _draw_key(Vector2(x + 48, y), "D", Vector2(42, 42))
    _draw_move_icon(Vector2(x + 102, y + 21))
    x += 156

    _draw_key(Vector2(x, y), "SPACE", Vector2(88, 42))
    _draw_jump_icon(Vector2(x + 105, y + 22))
    x += 158

    _draw_key(Vector2(x, y), "J", Vector2(42, 42))
    _draw_grab_icon(Vector2(x + 62, y + 21))
    x += 118

    # Throw cluster.
    _draw_key(Vector2(x, y), "K", Vector2(42, 42))
    _draw_arrow_key(Vector2(x + 50, y), Vector2.LEFT)
    _draw_throw_arc(Vector2(x + 112, y + 22), Vector2.LEFT)
    x += 162

    _draw_key(Vector2(x, y), "K", Vector2(42, 42))
    _draw_arrow_key(Vector2(x + 50, y), Vector2.RIGHT)
    _draw_throw_arc(Vector2(x + 112, y + 22), Vector2.RIGHT)
    x += 162

    _draw_key(Vector2(x, y), "K", Vector2(42, 42))
    _draw_arrow_key(Vector2(x + 50, y), Vector2.DOWN)
    _draw_slam_icon(Vector2(x + 112, y + 22))
    x += 162

    _draw_key(Vector2(x, y), "K", Vector2(42, 42))
    _draw_rear_icon(Vector2(x + 62, y + 21))
    x += 118

    _draw_key(Vector2(x, y), "R", Vector2(42, 42))
    _draw_reset_icon(Vector2(x + 62, y + 21))

func _draw_key(pos: Vector2, text: String, size: Vector2) -> void:
    var rect := Rect2(pos, size)
    draw_rect(rect, Color(0.97, 0.98, 1.0, 0.94), true)
    draw_rect(rect, Color(0.12, 0.15, 0.20, 0.90), false, 3.0)
    var font := ThemeDB.fallback_font
    var fs := 21 if text.length() <= 2 else 14
    var ts := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
    draw_string(font, pos + Vector2((size.x-ts.x)/2.0, (size.y+ts.y)/2.0-3.0), text,
        HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.10,0.12,0.16))

func _draw_arrow_key(pos: Vector2, dir: Vector2) -> void:
    _draw_key(pos, "", Vector2(42, 42))
    var c := pos + Vector2(21, 21)
    var d := dir.normalized()
    draw_line(c - d*10, c + d*10, Color(0.10,0.12,0.16), 4.0)
    var tip := c + d*11
    var n := Vector2(-d.y, d.x)
    draw_colored_polygon(PackedVector2Array([
        tip,
        tip - d*9 + n*6,
        tip - d*9 - n*6
    ]), Color(0.10,0.12,0.16))

func _draw_move_icon(c: Vector2) -> void:
    draw_line(c + Vector2(-20,0), c + Vector2(20,0), Color(0.10,0.12,0.16), 4.0)
    for d in [Vector2.LEFT, Vector2.RIGHT]:
        var tip := c + d*22
        var n := Vector2(-d.y, d.x)
        draw_colored_polygon(PackedVector2Array([tip, tip-d*8+n*5, tip-d*8-n*5]), Color(0.10,0.12,0.16))

func _draw_jump_icon(c: Vector2) -> void:
    draw_arc(c + Vector2(0,8), 17, PI, TAU, 18, Color(0.10,0.12,0.16), 4.0)
    draw_circle(c + Vector2(0,-11), 5, Color(0.10,0.12,0.16))

func _draw_grab_icon(c: Vector2) -> void:
    draw_circle(c + Vector2(-8,0), 8, Color(0.30,0.55,0.92))
    draw_circle(c + Vector2(8,0), 8, Color(0.82,0.36,0.34))
    draw_line(c + Vector2(-3,-5), c + Vector2(3,5), Color(0.10,0.12,0.16), 3.0)
    draw_line(c + Vector2(-3,5), c + Vector2(3,-5), Color(0.10,0.12,0.16), 3.0)

func _draw_throw_arc(c: Vector2, dir: Vector2) -> void:
    var flip := 1.0 if dir.x > 0 else -1.0
    var pts := PackedVector2Array()
    for i in range(11):
        var t := float(i)/10.0
        pts.append(c + Vector2(flip*(t*36.0-18.0), -sin(t*PI)*16.0))
    draw_polyline(pts, Color(0.90,0.20,0.16), 4.0)
    var tip := pts[pts.size()-1]
    var d := (pts[pts.size()-1]-pts[pts.size()-2]).normalized()
    var n := Vector2(-d.y,d.x)
    draw_colored_polygon(PackedVector2Array([tip,tip-d*8+n*5,tip-d*8-n*5]),Color(0.90,0.20,0.16))

func _draw_slam_icon(c: Vector2) -> void:
    draw_line(c + Vector2(0,-18), c + Vector2(0,12), Color(0.90,0.20,0.16), 4.0)
    draw_colored_polygon(PackedVector2Array([
        c+Vector2(0,17), c+Vector2(-6,7), c+Vector2(6,7)
    ]), Color(0.90,0.20,0.16))
    draw_line(c+Vector2(-16,18), c+Vector2(16,18), Color(0.10,0.12,0.16), 3.0)

func _draw_rear_icon(c: Vector2) -> void:
    draw_circle(c + Vector2(8,0), 8, Color(0.82,0.36,0.34))
    draw_circle(c + Vector2(-8,0), 7, Color(0.30,0.55,0.92))
    draw_arc(c, 19, 0.25*PI, 1.75*PI, 20, Color(0.90,0.20,0.16), 3.0)

func _draw_reset_icon(c: Vector2) -> void:
    draw_arc(c, 15, -0.2*PI, 1.55*PI, 20, Color(0.10,0.12,0.16), 4.0)
    var tip := c + Vector2(-14,-7)
    draw_colored_polygon(PackedVector2Array([tip, tip+Vector2(10,-2), tip+Vector2(4,8)]), Color(0.10,0.12,0.16))
