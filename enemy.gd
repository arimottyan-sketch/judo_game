extends CharacterBody2D

const GRAVITY := 1150.0

enum State { NORMAL, GRABBED, THROWN, DOWN }

var state := State.NORMAL
var facing := -1
var holder = null
var throw_name := ""
var impact_power := 0.0
var down_timer := 0.0
var kuzushi_dir := 0

var spin_speed := 0.0
var fx_power := 1.0
var trail_timer := 0.0
var force_slam := false
var air_time := 0.0

func _ready() -> void:
    add_to_group("enemy")
    collision_layer = 4
    collision_mask = 2

    var collider := CollisionShape2D.new()
    var shape := CapsuleShape2D.new()
    shape.radius = 18
    shape.height = 50
    collider.shape = shape
    add_child(collider)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if state == State.GRABBED:
        return

    if not is_on_floor():
        velocity.y += GRAVITY * delta

    if state == State.NORMAL:
        velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
        rotation = lerp_angle(rotation, 0.0, minf(1.0, 12.0 * delta))
    elif state == State.DOWN:
        down_timer -= delta
        velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
        if down_timer <= 0.0:
            state = State.NORMAL
            rotation = 0.0
    elif state == State.THROWN:
        air_time += delta
        rotation += spin_speed * delta

        if force_slam and air_time > 0.16:
            velocity.x = move_toward(velocity.x, 0.0, 950.0 * delta)
            velocity.y += 1200.0 * delta

        trail_timer -= delta
        if trail_timer <= 0.0 and velocity.length() > 320.0:
            trail_timer = 0.065
            _fx("spawn_trail", [global_position, velocity.normalized(), fx_power])

    var before := velocity
    move_and_slide()

    if state == State.THROWN and is_on_floor():
        var strength := clampf(fx_power + abs(before.y) / 750.0, 1.0, 2.6)
        _fx("spawn_impact", [global_position + Vector2(0, 25), strength])
        _fx("request_shake", [strength])
        state = State.DOWN
        down_timer = 0.9
        velocity = Vector2(before.x * 0.20, 0.0)
        spin_speed = 0.0
        force_slam = false
        air_time = 0.0
        rotation = deg_to_rad(72.0)
        queue_redraw()

    # Safety net for prototype: never let the test enemy be lost forever.
    if global_position.y > 850.0 or abs(global_position.x) > 4000.0:
        global_position = Vector2(520, 420)
        velocity = Vector2.ZERO
        rotation = 0.0
        state = State.NORMAL

func _fx(method: StringName, args: Array) -> void:
    for fx_node in get_tree().get_nodes_in_group("game_fx"):
        if fx_node.has_method(method):
            fx_node.callv(method, args)

func can_be_grabbed() -> bool:
    return state == State.NORMAL or state == State.DOWN

func is_player_behind(player_x: float) -> bool:
    return sign(player_x - global_position.x) == -facing

func begin_grab(by_player) -> void:
    holder = by_player
    state = State.GRABBED
    velocity = Vector2.ZERO
    kuzushi_dir = 0
    collision_layer = 0
    collision_mask = 0
    rotation = 0.0

func release_grab() -> void:
    holder = null
    state = State.NORMAL
    kuzushi_dir = 0
    collision_layer = 4
    collision_mask = 2
    rotation = 0.0

func set_kuzushi(direction: int) -> void:
    if state != State.GRABBED:
        return
    kuzushi_dir = clampi(direction, -1, 1)
    rotation = deg_to_rad(10.0 * kuzushi_dir)
    queue_redraw()

func receive_throw(initial_velocity: Vector2, damage: float, technique: String, angular_speed: float = 8.0, effect_power: float = 1.0, slam_mode: bool = false) -> void:
    holder = null
    state = State.THROWN
    velocity = initial_velocity
    impact_power = damage
    throw_name = technique
    collision_layer = 4
    collision_mask = 2
    kuzushi_dir = 0
    rotation = 0.0
    spin_speed = angular_speed
    fx_power = effect_power
    force_slam = slam_mode
    air_time = 0.0
    trail_timer = 0.0
    _fx("spawn_launch", [global_position, initial_velocity.normalized(), effect_power])
    _fx("request_shake", [0.3 * effect_power])

func _draw() -> void:
    # Bright outline so the enemy cannot visually blend into the background.
    draw_circle(Vector2(0, -20), 22, Color(1.0, 1.0, 1.0))
    draw_circle(Vector2(0, -20), 18, Color(0.93, 0.79, 0.62))
    draw_rect(Rect2(-21, -8, 42, 43), Color(1.0, 1.0, 1.0), true)
    draw_rect(Rect2(-18, -5, 36, 37), Color(0.82, 0.36, 0.34), true)
    draw_circle(Vector2(7 * facing, -23), 2.5, Color(0.05, 0.05, 0.05))
    draw_circle(Vector2(7 * facing, -16), 2.0, Color(0.05, 0.05, 0.05))

    if state == State.GRABBED and kuzushi_dir != 0:
        draw_circle(Vector2(-25 * kuzushi_dir, -30), 4, Color(0.35, 0.75, 1.0))
        draw_circle(Vector2(-29 * kuzushi_dir, -22), 2.5, Color(0.35, 0.75, 1.0))

    if state == State.THROWN:
        draw_arc(Vector2.ZERO, 33, 0, TAU, 18, Color(1, 1, 1, 0.72), 2.5)
