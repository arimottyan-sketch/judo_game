extends Node2D

const PlayerScript = preload("res://player.gd")
const EnemyScript = preload("res://enemy.gd")
const FxScript = preload("res://fx.gd")
const HudScript = preload("res://hud.gd")

var player
var enemy_a
var enemy_b
var camera: Camera2D
var shake_time := 0.0
var shake_strength := 0.0

func _ready() -> void:
    add_to_group("game_fx")
    _setup_input()

    # Long flat test floor.
    _make_ground(Vector2(800, 500), Vector2(1800, 80))

    # Player.
    player = PlayerScript.new()
    player.position = Vector2(330, 420)
    add_child(player)

    # Two enemies so disappearance is immediately obvious.
    enemy_a = EnemyScript.new()
    enemy_a.position = Vector2(560, 420)
    enemy_a.facing = -1
    add_child(enemy_a)

    enemy_b = EnemyScript.new()
    enemy_b.position = Vector2(850, 420)
    enemy_b.facing = -1
    add_child(enemy_b)

    # Fixed camera for debugging. No follow logic yet.
    camera = Camera2D.new()
    camera.position = Vector2(800, 270)
    camera.enabled = true
    add_child(camera)

    _make_ui()

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("reset"):
        get_tree().reload_current_scene()
        return

    if shake_time > 0.0:
        shake_time -= delta
        camera.offset = Vector2(
            randf_range(-shake_strength, shake_strength),
            randf_range(-shake_strength, shake_strength)
        )
    else:
        camera.offset = camera.offset.lerp(Vector2.ZERO, minf(1.0, 18.0 * delta))

func spawn_launch(pos: Vector2, direction: Vector2, power: float) -> void:
    var fx = FxScript.new()
    add_child(fx)
    fx.global_position = pos
    fx.setup("launch", direction, power, 0.22)

func spawn_trail(pos: Vector2, direction: Vector2, power: float) -> void:
    var fx = FxScript.new()
    add_child(fx)
    fx.global_position = pos
    fx.setup("trail", direction, power, 0.18)

func spawn_smoke(pos: Vector2, direction: Vector2, power: float) -> void:
    var fx = FxScript.new()
    add_child(fx)
    fx.global_position = pos
    fx.setup("smoke", direction, power, 0.68)

func spawn_impact(pos: Vector2, power: float) -> void:
    var fx = FxScript.new()
    add_child(fx)
    fx.global_position = pos
    fx.setup("impact", Vector2.UP, power, 0.22)

func request_shake(power: float) -> void:
    shake_time = maxf(shake_time, 0.10 + 0.025 * power)
    shake_strength = maxf(shake_strength, 2.5 + 3.5 * power)

func _make_ground(pos: Vector2, size: Vector2) -> void:
    var body := StaticBody2D.new()
    body.position = pos
    body.collision_layer = 2
    body.collision_mask = 0

    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    body.add_child(shape)

    var poly := Polygon2D.new()
    poly.polygon = PackedVector2Array([
        Vector2(-size.x / 2.0, -size.y / 2.0),
        Vector2(size.x / 2.0, -size.y / 2.0),
        Vector2(size.x / 2.0, size.y / 2.0),
        Vector2(-size.x / 2.0, size.y / 2.0)
    ])
    poly.color = Color(0.38, 0.58, 0.33)
    body.add_child(poly)
    add_child(body)

func _make_ui() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 20
    add_child(layer)

    var hud = HudScript.new()
    layer.add_child(hud)


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

    # Avoid duplicate bindings on scene reload.
    InputMap.action_erase_events(action)

    for keycode in keys:
        var ev := InputEventKey.new()
        ev.physical_keycode = keycode
        InputMap.action_add_event(action, ev)
