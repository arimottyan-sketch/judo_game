extends Node2D

const PlayerScript = preload("res://player.gd")
const EnemyScript = preload("res://enemy.gd")
const FxScript = preload("res://fx.gd")

var player
var enemy
var camera: Camera2D

var shake_time := 0.0
var shake_strength := 0.0
var hitstop_active := false

func _ready() -> void:
    add_to_group("game_fx")
    _setup_input()
    _setup_camera()

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

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("reset"):
        Engine.time_scale = 1.0
        get_tree().reload_current_scene()
        return

    if shake_time > 0.0:
        shake_time -= delta
        var falloff := clamp(shake_time / 0.20, 0.0, 1.0)
        camera.offset = Vector2(
            randf_range(-shake_strength, shake_strength),
            randf_range(-shake_strength, shake_strength)
        ) * falloff
    else:
        camera.offset = camera.offset.lerp(Vector2.ZERO, min(1.0, 18.0 * delta))

func _setup_camera() -> void:
    camera = Camera2D.new()
    camera.position = Vector2(480, 270)
    camera.enabled = true
    add_child(camera)

func spawn_launch(pos: Vector2, direction: Vector2, power: float) -> void:
    var fx = FxScript.new()
    add_child(fx)
    fx.global_position = pos
    fx.setup("launch", direction, power, 0.16)

func spawn_trail(pos: Vector2, direction: Vector2, power: float) -> void:
    var fx = FxScript.new()
    add_child(fx)
    fx.global_position = pos
    fx.setup("trail", direction, power, 0.16)

func spawn_impact(pos: Vector2, power: float, is_slam: bool = false) -> void:
    var fx = FxScript.new()
    add_child(fx)
    fx.global_position = pos
    fx.setup("slam" if is_slam else "impact", Vector2.UP, power, 0.30)

func request_shake(power: float) -> void:
    shake_time = max(shake_time, 0.10 + 0.035 * power)
    shake_strength = max(shake_strength, 3.0 + 4.2 * power)

func request_hitstop(duration: float) -> void:
    if hitstop_active:
        return
    _do_hitstop(duration)

func _do_hitstop(duration: float) -> void:
    hitstop_active = true
    Engine.time_scale = 0.10
    await get_tree().create_timer(duration, true, false, true).timeout
    Engine.time_scale = 1.0
    hitstop_active = false

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
    label.text = "A/D or ARROWS: MOVE    SPACE: JUMP    J: GRAB/RELEASE    R: RESET\nGRABBING: LEFT/RIGHT = KUZUSHI, NO WALKING\nFRONT: BACK+K TOMOE / FORWARD+K OSOTO / DOWN+K SEOI    REAR: K URA"
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
