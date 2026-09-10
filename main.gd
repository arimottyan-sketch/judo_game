extends Node2D

const PlayerScript = preload("res://player.gd")
const EnemyScript = preload("res://enemy.gd")

var player
var enemy

func _ready() -> void:
    _setup_input()
    _make_ground(Vector2(480, 500), Vector2(960, 80))
    _make_ground(Vector2(760, 410), Vector2(220, 24))

    player = PlayerScript.new()
    player.position = Vector2(250, 420)
    add_child(player)

    enemy = EnemyScript.new()
    enemy.position = Vector2(520, 420)
    enemy.facing = -1
    add_child(enemy)

    _make_ui()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("reset"):
        get_tree().reload_current_scene()

func _make_ground(pos: Vector2, size: Vector2) -> void:
    var body := StaticBody2D.new()
    body.position = pos

    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    body.add_child(shape)

    var poly := Polygon2D.new()
    poly.polygon = PackedVector2Array([
        Vector2(-size.x/2.0, -size.y/2.0),
        Vector2(size.x/2.0, -size.y/2.0),
        Vector2(size.x/2.0, size.y/2.0),
        Vector2(-size.x/2.0, size.y/2.0)
    ])
    poly.color = Color(0.38, 0.58, 0.33)
    body.add_child(poly)
    add_child(body)

func _make_ui() -> void:
    var label := Label.new()
    label.position = Vector2(22, 18)
    label.text = "A/D: 移動   SPACE: ジャンプ   J: 掴む/離す   K+方向: 投げ   R: リセット\n右向き・正面掴み:  ←+K 巴投   →+K 大外刈   ↓+K 背負投\n背後から掴む: Kで裏投（方向不問）"
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_color_override("font_color", Color(0.08, 0.10, 0.13))
    add_child(label)

func _setup_input() -> void:
    _bind_keys("move_left", [KEY_A, KEY_LEFT])
    _bind_keys("move_right", [KEY_D, KEY_RIGHT])
    _bind_keys("move_down", [KEY_S, KEY_DOWN])
    _bind_keys("jump", [KEY_SPACE])
    _bind_keys("grab", [KEY_J])
    _bind_keys("throw_action", [KEY_K])
    _bind_keys("reset", [KEY_R])

func _bind_keys(action: StringName, keys: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    for keycode in keys:
        var ev := InputEventKey.new()
        ev.physical_keycode = keycode
        InputMap.action_add_event(action, ev)
