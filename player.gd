extends CharacterBody2D

const SPEED := 240.0
const JUMP_VELOCITY := -410.0
const GRAVITY := 1150.0
const GRAB_RANGE := 58.0

var facing := 1
var held_enemy = null
var grabbed_from_behind := false
var was_on_floor := false

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
        # 掴み中は少しだけ動ける。後でここを「崩し」に置き換える。
        velocity.x = axis * SPEED * 0.28
        held_enemy.global_position = global_position + Vector2(36 * facing, -2)
        held_enemy.velocity = Vector2.ZERO

    if Input.is_action_just_pressed("grab"):
        if held_enemy == null:
            _try_grab()
        else:
            _release_enemy()

    if held_enemy != null and Input.is_action_just_pressed("throw_action"):
        _try_throw()

    move_and_slide()
    was_on_floor = is_on_floor()
    queue_redraw()

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
        # 基本的には向いている側の敵だけ掴める。
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
    queue_redraw()

func _release_enemy() -> void:
    if held_enemy == null:
        return
    held_enemy.release_grab()
    held_enemy = null
    grabbed_from_behind = false

func _try_throw() -> void:
    if held_enemy == null:
        return

    # 背後から掴んだ場合は方向入力に関係なく裏投。
    if grabbed_from_behind:
        _perform_throw("uranage")
        return

    var left := Input.is_action_pressed("move_left")
    var right := Input.is_action_pressed("move_right")
    var down := Input.is_action_pressed("move_down")

    # 入力はワールド方向ではなく「主人公の向きに対する前後」に変換。
    var pressing_back := left if facing == 1 else right
    var pressing_forward := right if facing == 1 else left

    if down:
        _perform_throw("seoi")
    elif pressing_back:
        _perform_throw("tomoe")
    elif pressing_forward:
        _perform_throw("osoto")
    # 方向なしでは何もしない（正面掴み）。

func _perform_throw(kind: String) -> void:
    var enemy = held_enemy
    held_enemy = null

    match kind:
        "osoto":
            # 敵の背中側＝主人公の前方へ短く倒す。
            enemy.receive_throw(Vector2(260.0 * facing, -80.0), 1.0, "大外刈")
        "seoi":
            # 自分の背後斜め下へ。着地を強めに。
            enemy.receive_throw(Vector2(-330.0 * facing, -150.0), 1.5, "背負投")
        "tomoe":
            # 自分の背後へ長距離。
            enemy.receive_throw(Vector2(-590.0 * facing, -250.0), 1.3, "巴投")
        "uranage":
            # ほぼその場で叩きつける。
            enemy.receive_throw(Vector2(45.0 * facing, 380.0), 2.5, "裏投")

    grabbed_from_behind = false

func _draw() -> void:
    # 2.5頭身くらいを想定した仮キャラ。
    draw_circle(Vector2(0, -20), 17, Color(1.0, 0.86, 0.48))
    draw_rect(Rect2(-15, -5, 30, 35), Color(0.30, 0.55, 0.92), true)
    # 顔の向き。
    draw_circle(Vector2(6 * facing, -23), 2.2, Color(0.08, 0.08, 0.08))
    draw_line(Vector2(-8, 29), Vector2(-11, 38), Color(0.1,0.1,0.1), 4)
    draw_line(Vector2(8, 29), Vector2(11, 38), Color(0.1,0.1,0.1), 4)
    if held_enemy != null:
        draw_arc(Vector2(0, -2), 29, 0, TAU, 24, Color(1,1,1,0.75), 2)
