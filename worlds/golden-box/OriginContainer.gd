extends VBoxContainer


onready var world_scale_label = $WorldScale as Label
onready var position_label = $TransformContainer/Position as Label
onready var rotation_label = $TransformContainer/Rotation as Label


func _process(_delta: float) -> void:
    var origin = InputMapper.vr_origin
    if origin:
        display_scale(origin)
        display_transform(origin)


func display_scale(origin):
    world_scale_label.text = "World scale: {}".format([origin.world_scale], "{}")


func display_transform(origin):
    var tr = origin.translation
    var rd = origin.rotation_degrees
    var posarr = ["%2.3f" % tr.x, "%2.3f" % tr.y, "%2.3f" % tr.z]
    var rotarr = ["%2.3f" % rd.x, "%2.3f" % rd.y, "%2.3f" % rd.z]
    position_label.text = "Position\nX:  {}\nY:  {}\nZ: {}".format(posarr, "{}")
    rotation_label.text = "Rotation\nX:  {}\nY:  {}\nZ: {}".format(rotarr, "{}")
