extends CharacterBody2D

const SPEED := 240.0
const JUMP_VELOCITY := -410.0
const GRAVITY := 1150.0
const GRAB_RANGE := 58.0
const THROW_INPUT_BUFFER := 0.18

var facing := 1
var held_enemy = null
var grabbed_from_behind := false
var throw_buffer := 0.0

func _ready() -> void:
    add_to_group("player")
    collision_layer = 1
    collision_mask = 1

    var collider := CollisionShape2D.new()
    var shape := CapsuleShape2D.new()
    shape.radius = 16
    shape.height = 48
    collider.shape = shape
    add_child(collider)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    if throw_buffer > 0.0:
        throw_buffer -= delta

    if Input.is_action_just_pressed("jump") and is_on_floor() and held_enemy == null:
        velocity.y = JUMP_VELOCITY

    var axis := Input.get_axis("move_left", "move_right")

    if held_enemy == null:
        if abs(axis) > 0.01:
            facing = 1 if axis > 0 else -1
            velocity.x = axis * SPEED
        else:
            velocity.x = move_toward(velocity.x, 0.0, SPEED * 6.0 * delta)
    else:
        # Grab state: normal walking is completely disabled.
        # Left/right/down are reserved for kuzushi and throw selection.
        velocity.x = 0.0
        held_enemy.global_position = global_position + Vector2(36 * facing, -2)
        held_enemy.velocity = Vector2.ZERO
        _update_kuzushi_input()

    if Input.is_action_just_pressed("grab"):
        if held_enemy == null:
            _try_grab()
        else:
            _release_enemy()

    if held_enemy != null:
        _update_throw_input(delta)

    move_and_slide()
    queue_redraw()

func _update_throw_input(_delta: float) -> void:
    if held_enemy == null:
        return

    # Rear grab: K alone is Ura-nage.
    if grabbed_from_behind and Input.is_action_just_pressed("throw_action"):
        _perform_throw("uranage")
        return

    # Buffer K briefly, so K -> direction and direction -> K both work.
    if Input.is_action_just_pressed("throw_action"):
        throw_buffer = THROW_INPUT_BUFFER

    var direction_just_pressed := (
        Input.is_action_just_pressed("move_left")
        or Input.is_action_just_pressed("move_right")
        or Input.is_action_just_pressed("move_down")
    )

    var throw_requested := Input.is_action_just_pressed("throw_action") or (
        direction_just_pressed and (Input.is_action_pressed("throw_action") or throw_buffer > 0.0)
    )

    if not throw_requested:
        return

    var left := Input.is_action_pressed("move_left")
    var right := Input.is_action_pressed("move_right")
    var down := Input.is_action_pressed("move_down")

    var pressing_back := left if facing == 1 else right
    var pressing_forward := right if facing == 1 else left

    if down:
        _perform_throw("seoi")
    elif pressing_back:
        _perform_throw("tomoe")
    elif pressing_forward:
        _perform_throw("osoto")

func _update_kuzushi_input() -> void:
    if held_enemy == null or grabbed_from_behind:
        return

    # For v0.2 this is visual feedback only.
    # Later enemy types will require the correct kuzushi before a throw succeeds.
    var left := Input.is_action_pressed("move_left")
    var right := Input.is_action_pressed("move_right")

    var pressing_back := left if facing == 1 else right
    var pressing_forward := right if facing == 1 else left

    if pressing_forward and not pressing_back:
        held_enemy.set_kuzushi(1)
    elif pressing_back and not pressing_forward:
        held_enemy.set_kuzushi(-1)
    else:
        held_enemy.set_kuzushi(0)

func _try_grab() -> void:
    var best = null
    var best_dist := INF
    for candidate in get_tree().get_nodes_in_group("enemy"):
        if not candidate.can_be_grabbed():
            continue
        var dx: float = candidate.global_position.x - global_position.x
        var dy: float = abs(candidate.global_position.y - global_position.y)
        if dy > 50.0:
            continue
        if sign(dx) != facing:
            continue
        var dist := abs(dx)
        if dist <= GRAB_RANGE and dist < best_dist:
            best = candidate
            best_dist = dist

    if best == null:
        return

    held_enemy = best
    grabbed_from_behind = held_enemy.is_player_behind(global_position.x)
    held_enemy.begin_grab(self)
    held_enemy.global_position = global_position + Vector2(36 * facing, -2)
    velocity.x = 0.0
    throw_buffer = 0.0
    queue_redraw()

func _release_enemy() -> void:
    if held_enemy == null:
        return
    held_enemy.set_kuzushi(0)
    held_enemy.release_grab()
    held_enemy = null
    grabbed_from_behind = false
    throw_buffer = 0.0

func _perform_throw(kind: String) -> void:
    if held_enemy == null:
        return

    var enemy = held_enemy
    held_enemy = null
    throw_buffer = 0.0

    match kind:
        "osoto":
            enemy.receive_throw(Vector2(260.0 * facing, -80.0), 1.0, "OSOTO")
        "seoi":
            enemy.receive_throw(Vector2(-330.0 * facing, -150.0), 1.5, "SEOI")
        "tomoe":
            enemy.receive_throw(Vector2(-590.0 * facing, -250.0), 1.3, "TOMOE")
        "uranage":
            enemy.receive_throw(Vector2(45.0 * facing, 380.0), 2.5, "URA")

    grabbed_from_behind = false

func _draw() -> void:
    draw_circle(Vector2(0, -20), 17, Color(1.0, 0.86, 0.48))
    draw_rect(Rect2(-15, -5, 30, 35), Color(0.30, 0.55, 0.92), true)
    draw_circle(Vector2(6 * facing, -23), 2.2, Color(0.08, 0.08, 0.08))
    draw_line(Vector2(-8, 29), Vector2(-11, 38), Color(0.1,0.1,0.1), 4)
    draw_line(Vector2(8, 29), Vector2(11, 38), Color(0.1,0.1,0.1), 4)
    if held_enemy != null:
        draw_arc(Vector2(0, -2), 29, 0, TAU, 24, Color(1,1,1,0.75), 2)
