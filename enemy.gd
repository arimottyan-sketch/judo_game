extends CharacterBody2D

const GRAVITY := 1150.0

enum State { NORMAL, GRABBED, THROWN, DOWN }

var state := State.NORMAL
var facing := -1
var holder = null
var throw_name := ""
var impact_power := 0.0
var down_timer := 0.0
var hp := 4.0
var kuzushi_dir := 0

var spin_speed := 0.0
var fx_power := 1.0
var trail_timer := 0.0
var force_slam := false
var time_in_air := 0.0

func _ready() -> void:
    add_to_group("enemy")
    collision_layer = 1
    collision_mask = 1

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
        rotation = lerp_angle(rotation, 0.0, min(1.0, 12.0 * delta))
    elif state == State.DOWN:
        down_timer -= delta
        velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
        rotation = lerp_angle(rotation, deg_to_rad(78.0), min(1.0, 10.0 * delta))
        if down_timer <= 0.0:
            state = State.NORMAL
            throw_name = ""
            rotation = 0.0
    elif state == State.THROWN:
        time_in_air += delta
        rotation += spin_speed * delta

        # Ura-nage rises briefly and then is pulled into a violent near-vertical slam.
        if force_slam and time_in_air > 0.18:
            velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
            velocity.y += 1500.0 * delta

        trail_timer -= delta
        if trail_timer <= 0.0 and velocity.length() > 280.0:
            trail_timer = 0.045 if fx_power >= 1.4 else 0.07
            _fx("spawn_trail", [global_position, velocity.normalized(), fx_power])

    var before_velocity := velocity
    move_and_slide()

    if state == State.THROWN and is_on_floor():
        var landing_speed := abs(before_velocity.y)
        var horizontal_speed := abs(before_velocity.x)
        var total_impact := impact_power + landing_speed / 430.0 + horizontal_speed / 1050.0
        hp -= total_impact

        var slam_strength := clamp(fx_power + landing_speed / 700.0, 1.0, 2.8)
        _fx("spawn_impact", [global_position + Vector2(0, 26), slam_strength, throw_name == "URA"])
        _fx("request_shake", [slam_strength])
        _fx("request_hitstop", [0.035 + 0.018 * slam_strength])

        state = State.DOWN
        down_timer = 0.85 + 0.18 * fx_power
        velocity.x *= 0.26
        velocity.y = 0.0
        force_slam = false
        spin_speed = 0.0
        time_in_air = 0.0
        queue_redraw()

func _fx(method: StringName, args: Array) -> void:
    for fx_node in get_tree().get_nodes_in_group("game_fx"):
        if fx_node.has_method(method):
            fx_node.callv(method, args)

func can_be_grabbed() -> bool:
    return state == State.NORMAL or state == State.DOWN

func is_player_behind(player_x: float) -> bool:
    var player_side := sign(player_x - global_position.x)
    return player_side == -facing

func begin_grab(by_player) -> void:
    holder = by_player
    state = State.GRABBED
    velocity = Vector2.ZERO
    kuzushi_dir = 0
    collision_layer = 0
    collision_mask = 0
    spin_speed = 0.0
    force_slam = false
    rotation = 0.0
    queue_redraw()

func release_grab() -> void:
    holder = null
    state = State.NORMAL
    kuzushi_dir = 0
    rotation = 0.0
    collision_layer = 1
    collision_mask = 1
    queue_redraw()

func set_kuzushi(direction: int) -> void:
    if state != State.GRABBED:
        return
    kuzushi_dir = clampi(direction, -1, 1)
    rotation = deg_to_rad(10.0 * kuzushi_dir)
    queue_redraw()

func receive_throw(
    initial_velocity: Vector2,
    damage: float,
    technique: String,
    angular_speed: float = 8.0,
    effect_power: float = 1.0,
    slam_mode: bool = false
) -> void:
    holder = null
    state = State.THROWN
    velocity = initial_velocity
    impact_power = damage
    throw_name = technique
    kuzushi_dir = 0
    rotation = 0.0
    collision_layer = 1
    collision_mask = 1

    spin_speed = angular_speed
    fx_power = effect_power
    trail_timer = 0.0
    force_slam = slam_mode
    time_in_air = 0.0

    _fx("spawn_launch", [global_position, initial_velocity.normalized(), effect_power])
    _fx("request_shake", [0.35 * effect_power])
    queue_redraw()

func _draw() -> void:
    var body_color := Color(0.82, 0.36, 0.34)
    if state == State.DOWN:
        body_color = Color(0.72, 0.30, 0.30)

    draw_circle(Vector2(0, -20), 18, Color(0.93, 0.79, 0.62))
    draw_rect(Rect2(-18, -5, 36, 37), body_color, true)
    draw_circle(Vector2(7 * facing, -23), 2.5, Color(0.05,0.05,0.05))
    draw_circle(Vector2(7 * facing, -16), 2.0, Color(0.05,0.05,0.05))

    if state == State.GRABBED and kuzushi_dir != 0:
        draw_circle(Vector2(-25 * kuzushi_dir, -30), 4, Color(0.35,0.75,1.0))
        draw_circle(Vector2(-29 * kuzushi_dir, -22), 2.5, Color(0.35,0.75,1.0))

    if state == State.THROWN:
        # Airflow ring around the thrown enemy.
        draw_arc(Vector2.ZERO, 33, 0, TAU, 18, Color(1,1,1,0.72), 2.5)

    if state == State.DOWN:
        draw_circle(Vector2(-25, -28), 4, Color(0.35,0.75,1.0))
