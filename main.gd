extends Node3D

# Lightweight 2.5D city prototype. Uses simple 3D geometry to stay mobile-friendly.
var player: CharacterBody3D
var camera: Camera3D
var move_vector := Vector2.ZERO
var coins := 250
var outfit := 0
var in_car := false
var message_timer := 0.0
var ui_message: Label
var coins_label: Label
var outfit_colors = [Color("#e4ad43"), Color("#287e9b"), Color("#cf6846")]

func _ready() -> void:
    _build_world()
    _build_player()
    _build_camera()
    _build_ui()
    _say("Welcome to Assigamé, Lomé! Use the joystick to explore.")

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color("#5e9bc0")
    sky_mat.sky_horizon_color = Color("#e8c99b")
    sky_mat.ground_bottom_color = Color("#263326")
    sky_mat.ground_horizon_color = Color("#b6a17b")
    environment.sky.sky_material = sky_mat
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#d9d0b7")
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.25
    sun.shadow_enabled = false
    add_child(sun)

    _box("Ground", Vector3(0, -0.25, 0), Vector3(48, 0.5, 48), Color("#304632"))
    _box("Main asphalt road", Vector3(0, 0.015, 0), Vector3(5.5, 0.05, 46), Color("#77786e"))
    _box("Cross street", Vector3(0, 0.02, 0), Vector3(46, 0.06, 4.2), Color("#77786e"))
    for i in range(-20, 21, 3):
        _box("Road marking", Vector3(0, 0.06, i), Vector3(0.12, 0.025, 1.2), Color("#f0e2b8"))
        _box("Cross marking", Vector3(i, 0.065, 0), Vector3(1.2, 0.025, 0.12), Color("#f0e2b8"))

    # Houses and shops positioned along the roads.
    _house("TAILOR HOUSE", Vector3(-6.5, 0, -7.5), Vector3(4.4, 2.5, 3.8), Color("#c6b38d"), Color("#8c5942"))
    _house("MINI MARKET", Vector3(6.5, 0, -8), Vector3(4.6, 2.4, 4.0), Color("#c5c9a4"), Color("#a76848"))
    _house("BOUTIQUE", Vector3(-7.5, 0, 5.8), Vector3(4.5, 2.4, 3.8), Color("#d1bd95"), Color("#995d45"))
    _house("GARAGE AUTO", Vector3(7.3, 0, 6.8), Vector3(4.8, 2.3, 4.0), Color("#b7c19d"), Color("#8f5941"))
    _house("APARTMENTS", Vector3(-11, 0, -1.0), Vector3(3.8, 4.0, 4.5), Color("#d4c3a4"), Color("#94674e"))
    _house("PHARMACIE", Vector3(11, 0, 1.0), Vector3(4.0, 2.5, 4.0), Color("#d2bd98"), Color("#a35f43"))

    for pos in [Vector3(-12,0,-10), Vector3(12,0,-10), Vector3(-12,0,10), Vector3(12,0,10), Vector3(4,0,-13), Vector3(-4,0,13)]:
        _tree(pos)

    _npc("Ama", Vector3(-3.8, 0, -2.5), Color("#d96f43"))
    _npc("Mawuli", Vector3(3.8, 0, -3.5), Color("#4383b6"))
    _npc("Kossi", Vector3(5.0, 0, 3.4), Color("#4b9c88"))
    _npc("Yao", Vector3(-4.5, 0, 4.0), Color("#bd5b89"))
    _car(Vector3(-1.8, 0.15, 5.0), Color("#e1b445"))
    _car(Vector3(1.8, 0.15, -5.5), Color("#398d92"))

func _box(n: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = n
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 1.0
    node.material_override = mat
    add_child(node)
    return node

func _house(label: String, pos: Vector3, size: Vector3, wall: Color, roof: Color) -> void:
    _box(label + " walls", pos + Vector3(0, size.y/2, 0), size, wall)
    var roof_node := _box(label + " roof", pos + Vector3(0, size.y + 0.16, 0), Vector3(size.x + 0.45, 0.32, size.z + 0.45), roof)
    # Front door and two blue windows face toward the road.
    _box(label + " door", pos + Vector3(0, 0.8, size.z/2 + 0.025), Vector3(0.62, 1.55, 0.08), Color("#634835"))
    _box(label + " window left", pos + Vector3(-size.x*0.27, size.y*0.63, size.z/2 + 0.035), Vector3(0.68, 0.62, 0.08), Color("#6a9c9e"))
    _box(label + " window right", pos + Vector3(size.x*0.27, size.y*0.63, size.z/2 + 0.035), Vector3(0.68, 0.62, 0.08), Color("#6a9c9e"))
    var sign := Label3D.new()
    sign.text = label
    sign.font_size = 30
    sign.pixel_size = 0.006
    sign.position = pos + Vector3(0, size.y + 0.65, size.z/2 + 0.1)
    sign.modulate = Color("#fff0c9")
    add_child(sign)

func _tree(pos: Vector3) -> void:
    var trunk := _box("Palm trunk", pos + Vector3(0, 0.9, 0), Vector3(0.28, 1.8, 0.28), Color("#725036"))
    var crown := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.85
    mesh.height = 1.5
    crown.mesh = mesh
    crown.position = pos + Vector3(0, 2.1, 0)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#3f7647")
    crown.material_override = mat
    add_child(crown)

func _npc(n: String, pos: Vector3, shirt: Color) -> void:
    var body := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.28
    capsule.height = 1.25
    body.mesh = capsule
    body.position = pos + Vector3(0, 0.72, 0)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = shirt
    body.material_override = mat
    add_child(body)
    var head := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.22
    head.mesh = sphere
    head.position = pos + Vector3(0, 1.48, 0)
    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color("#805136")
    head.material_override = skin
    add_child(head)
    var tag := Label3D.new()
    tag.text = n
    tag.font_size = 26
    tag.pixel_size = 0.008
    tag.position = pos + Vector3(0, 2.0, 0)
    tag.modulate = Color("#fff4d5")
    add_child(tag)

func _car(pos: Vector3, color: Color) -> void:
    _box("Taxi body", pos + Vector3(0, 0.42, 0), Vector3(1.6, 0.7, 2.5), color)
    _box("Taxi cabin", pos + Vector3(0, 0.92, -0.1), Vector3(1.25, 0.48, 1.25), Color("#82a6a3"))

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 0.95, 2.0)
    var body := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.3
    mesh.height = 1.5
    body.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = outfit_colors[outfit]
    body.material_override = mat
    player.add_child(body)
    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.23
    head.mesh = head_mesh
    head.position = Vector3(0, 0.82, 0)
    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color("#805136")
    head.material_override = skin
    player.add_child(head)
    var collider := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.3
    shape.height = 1.5
    collider.shape = shape
    player.add_child(collider)
    add_child(player)

func _build_camera() -> void:
    camera = Camera3D.new()
    camera.position = Vector3(12, 12, 15)
    camera.rotation_degrees = Vector3(-32, 38, 0)
    camera.current = true
    add_child(camera)

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(root)

    var title := Label.new()
    title.text = "🌴 LIFE IN LOMÉ CITY\\nASSIGAMÉ • LOMÉ, TOGO"
    title.position = Vector2(18, 14)
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", Color("#fff0c9"))
    root.add_child(title)

    coins_label = Label.new()
    coins_label.text = "☀ 08:00     🪙 250     ♥ 75"
    coins_label.anchor_left = 1.0
    coins_label.anchor_right = 1.0
    coins_label.offset_left = -300
    coins_label.offset_right = -18
    coins_label.offset_top = 20
    coins_label.offset_bottom = 60
    coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    coins_label.add_theme_font_size_override("font_size", 18)
    coins_label.add_theme_color_override("font_color", Color("#fff0c9"))
    root.add_child(coins_label)

    ui_message = Label.new()
    ui_message.position = Vector2(18, 76)
    ui_message.size = Vector2(600, 48)
    ui_message.add_theme_font_size_override("font_size", 16)
    ui_message.add_theme_color_override("font_color", Color("#f6d780"))
    root.add_child(ui_message)

    var joystick := Control.new()
    joystick.name = "Joystick"
    joystick.position = Vector2(24, -176)
    joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    joystick.size = Vector2(150, 150)
    root.add_child(joystick)
    var ring := ColorRect.new()
    ring.position = Vector2.ZERO
    ring.size = Vector2(144, 144)
    ring.color = Color(0.04, 0.1, 0.07, 0.55)
    ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ring.add_theme_stylebox_override("panel", StyleBoxFlat.new())
    joystick.add_child(ring)
    var knob := Button.new()
    knob.name = "Knob"
    knob.text = "●"
    knob.position = Vector2(47, 47)
    knob.size = Vector2(52, 52)
    knob.add_theme_font_size_override("font_size", 28)
    knob.pressed.connect(func(): pass)
    joystick.add_child(knob)
    joystick.gui_input.connect(_on_joystick_input.bind(joystick, knob))

    var buttons := VBoxContainer.new()
    buttons.anchor_left = 1.0
    buttons.anchor_right = 1.0
    buttons.anchor_top = 0.38
    buttons.anchor_bottom = 0.38
    buttons.offset_left = -180
    buttons.offset_right = -12
    buttons.offset_top = 0
    buttons.offset_bottom = 320
    buttons.add_theme_constant_override("separation", 7)
    root.add_child(buttons)
    _add_button(buttons, "ENTER / TALK", _talk)
    _add_button(buttons, "ENTER / EXIT CAR", _car_action)
    _add_button(buttons, "CHANGE LOOK", _change_look)
    _add_button(buttons, "QUICK TASK +25", _quick_task)
    _add_button(buttons, "RESET POSITION", _reset_player)

func _add_button(parent: VBoxContainer, text_value: String, callback: Callable) -> void:
    var b := Button.new()
    b.text = text_value
    b.custom_minimum_size = Vector2(160, 44)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 14)
    b.add_theme_color_override("font_color", Color("#fff0c9"))
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#10231b")
    style.border_color = Color("#a58b50")
    style.set_border_width_all(1)
    style.set_corner_radius_all(12)
    b.add_theme_stylebox_override("normal", style)
    buttons_style_hover(b)
    b.pressed.connect(callback)
    parent.add_child(b)

func buttons_style_hover(b: Button) -> void:
    var hover := StyleBoxFlat.new()
    hover.bg_color = Color("#554a2d")
    hover.border_color = Color("#f0d58c")
    hover.set_border_width_all(1)
    hover.set_corner_radius_all(12)
    b.add_theme_stylebox_override("hover", hover)
    b.add_theme_stylebox_override("pressed", hover)

func _on_joystick_input(event: InputEvent, control: Control, knob: Button) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _set_stick(event.position, control, knob)
        else:
            move_vector = Vector2.ZERO
            knob.position = Vector2(47, 47)
    elif event is InputEventScreenDrag:
        _set_stick(event.position, control, knob)
    elif event is InputEventMouseButton:
        if event.pressed:
            _set_stick(event.position, control, knob)
        else:
            move_vector = Vector2.ZERO
            knob.position = Vector2(47, 47)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        _set_stick(event.position, control, knob)

func _set_stick(pos: Vector2, control: Control, knob: Button) -> void:
    var center := control.size / 2.0
    var delta := pos - center
    var radius := 44.0
    if delta.length() > radius:
        delta = delta.normalized() * radius
    move_vector = Vector2(delta.x / radius, delta.y / radius)
    knob.position = center + delta - knob.size / 2.0

func _physics_process(delta: float) -> void:
    var input_vec := move_vector
    input_vec.x += Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    input_vec.y += Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    if input_vec.length() > 1.0:
        input_vec = input_vec.normalized()
    var speed := 4.6 if in_car else 2.8
    player.velocity.x = input_vec.x * speed
    player.velocity.z = input_vec.y * speed
    player.velocity.y = 0.0
    player.move_and_slide()
    var target := player.global_position + Vector3(0, 8.5, 10.5)
    camera.global_position = camera.global_position.lerp(target, min(delta * 3.0, 1.0))
    camera.look_at(player.global_position + Vector3(0, 0.7, 0), Vector3.UP)

func _talk() -> void:
    var nearest := 999.0
    var who := ""
    for n in get_children():
        if n is Label3D and n.text in ["Ama", "Mawuli", "Kossi", "Yao"]:
            var d : float = n.global_position.distance_to(player.global_position)
            if d < nearest:
                nearest = d
                who = n.text
    if nearest < 4.5:
        coins += 5
        coins_label.text = "☀ 08:00     🪙 %d     ♥ 75" % coins
        _say(who + ": " + "Bienvenue à Lomé! Welcome to our neighbourhood.")
    else:
        _say("Move closer to a resident, then tap ENTER / TALK.")

func _car_action() -> void:
    in_car = not in_car
    _say("Taxi mode on. Use the joystick to drive." if in_car else "You stepped out of the taxi.")

func _change_look() -> void:
    outfit = (outfit + 1) % outfit_colors.size()
    var body := player.get_child(0) as MeshInstance3D
    var mat := StandardMaterial3D.new()
    mat.albedo_color = outfit_colors[outfit]
    body.material_override = mat
    _say("Outfit changed!")

func _quick_task() -> void:
    coins += 25
    coins_label.text = "☀ 08:00     🪙 %d     ♥ 75" % coins
    _say("Quick task completed! +25 coins.")

func _reset_player() -> void:
    player.position = Vector3(0, 0.95, 2)
    in_car = false
    _say("Back at the Assigamé starting point.")

func _say(text_value: String) -> void:
    ui_message.text = text_value
    message_timer = 3.0
