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
    elif state == State.DOWN:
        down_timer -= delta
        velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
        if down_timer <= 0.0:
            state = State.NORMAL
            throw_name = ""
    elif state == State.THROWN:
        # 空中は慣性を保つ。床についたらダウンへ。
        pass

    var before_vy := velocity.y
    move_and_slide()

    if state == State.THROWN and is_on_floor():
        var landing_speed := abs(before_vy)
        hp -= impact_power + landing_speed / 420.0
        state = State.DOWN
        down_timer = 1.0
        velocity.x *= 0.30
        velocity.y = 0.0
        queue_redraw()

func can_be_grabbed() -> bool:
    return state == State.NORMAL or state == State.DOWN

func is_player_behind(player_x: float) -> bool:
    # facing=+1なら右が顔側、左が背中側。
    # facing=-1なら左が顔側、右が背中側。
    var player_side := sign(player_x - global_position.x)
    return player_side == -facing

func begin_grab(by_player) -> void:
    holder = by_player
    state = State.GRABBED
    velocity = Vector2.ZERO
    collision_layer = 0
    collision_mask = 0
    queue_redraw()

func release_grab() -> void:
    holder = null
    state = State.NORMAL
    collision_layer = 1
    collision_mask = 1
    queue_redraw()

func receive_throw(initial_velocity: Vector2, damage: float, technique: String) -> void:
    holder = null
    state = State.THROWN
    velocity = initial_velocity
    impact_power = damage
    throw_name = technique
    collision_layer = 1
    collision_mask = 1
    queue_redraw()

func _draw() -> void:
    var body_color := Color(0.82, 0.36, 0.34)
    if state == State.DOWN:
        body_color = Color(0.72, 0.30, 0.30)

    draw_circle(Vector2(0, -20), 18, Color(0.93, 0.79, 0.62))
    draw_rect(Rect2(-18, -5, 36, 37), body_color, true)
    # 顔を明示して前後判定が視覚的に分かるようにする。
    draw_circle(Vector2(7 * facing, -23), 2.5, Color(0.05,0.05,0.05))
    draw_circle(Vector2(7 * facing, -16), 2.0, Color(0.05,0.05,0.05))

    if state == State.THROWN:
        draw_arc(Vector2.ZERO, 32, 0, TAU, 18, Color(1,1,1,0.65), 2)
    if state == State.DOWN:
        # 汗っぽい記号。後の崩し表示にも流用予定。
        draw_circle(Vector2(-25, -28), 4, Color(0.35,0.75,1.0))
