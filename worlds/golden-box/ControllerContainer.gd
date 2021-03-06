extends HBoxContainer


export var controller_id: int = 0


onready var position_label = $LeftContainer/TransformContainer/Position as Label
onready var rotation_label = $LeftContainer/TransformContainer/Rotation as Label
onready var buttons_label = $RightContainer/AllButtons as Label
onready var axes_label = $LeftContainer/AllAxes as Label
onready var name_label = $LeftContainer/Name as Label
onready var hand_label = $LeftContainer/Hand as Label
onready var active_label = $LeftContainer/Active as Label
onready var joystick_label = $LeftContainer/Joystick as Label
onready var mesh_update_label = $LeftContainer/MeshUpdate as Label
onready var button_event_label = $LeftContainer/ButtonEvent as Label


var mesh_counter = 0


var controller = null
func _process(_delta: float) -> void:
    save_controller()
    if controller:
        display_basics()
        display_all_button_states()
        display_all_axes_states()
        display_transform()


func save_controller():
    var c = get_controller() as ARVRController
    if not controller == c:
        controller = c
        subscribe_to_controller_signals()


func display_transform():
    var tr = controller.translation
    var rd = controller.rotation_degrees
    var posarr = ["%2.3f" % tr.x, "%2.3f" % tr.y, "%2.3f" % tr.z]
    var rotarr = ["%2.3f" % rd.x, "%2.3f" % rd.y, "%2.3f" % rd.z]
    position_label.text = "Position\nX:  {}\nY:  {}\nZ: {}".format(posarr, "{}")
    rotation_label.text = "Rotation\nX:  {}\nY:  {}\nZ: {}".format(rotarr, "{}")


func display_all_button_states():
    var text = "All buttons:\n"
    for i in JOY_BUTTON_MAX:
        text = text + "button {}    |{}|\n".format(["%2d" % i, "X" if controller.is_button_pressed(i) else "  "], "{}")
    buttons_label.text = text


func display_all_axes_states():
    var text = "All axes:\n"
    for i in JOY_AXIS_MAX:
        text = text + "axis {}    {}\n".format(["%3d" % i, "%0.2f" % controller.get_joystick_axis(i)], "{}")
    axes_label.text = text


func display_basics():
    name_label.text = "Name: {}".format([controller.get_name()], "{}")
    hand_label.text = "Hand: {}".format([controller.get_hand()], "{}")
    active_label.text = "Active: {}".format([controller.get_is_active()], "{}")
    joystick_label.text = "Joystick: {}".format([controller.get_joystick_id()], "{}")
    mesh_update_label.text = "Mesh updated {} times".format([mesh_counter], "{}")


func subscribe_to_controller_signals() -> void:
    if controller:
        controller.connect("mesh_updated", self, "_on_mesh_updated")
        controller.connect("button_pressed", self, "_on_button_pressed")
        controller.connect("button_release", self, "_on_button_released")


func get_controller() -> ARVRController:
    var origin = InputMapper.vr_origin
    if origin:
        return (origin.left if controller_id == 1 else origin.right if controller_id == 2 else null)
    return null


func _on_mesh_updated() -> void:
    mesh_counter = mesh_counter + 1

func _on_button_pressed(button: int) -> void:
    _on_button_action(button, "pressed")

func _on_button_released(button: int) -> void:
    _on_button_action(button, "released")

func _on_button_action(button: int, action: String) -> void:
    button_event_label.text = "Button {} {}".format(["%2d" % button, action], "{}")
