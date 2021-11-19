extends Spatial


onready var reflection_portal = $ReflectionPortal
onready var reflection_probe = $ReflectionProbe
onready var freemove_portal = $LocomotionPortal


func _ready() -> void:
    reflection_portal.connect("body_entered", self, "_reflection_portal_activated")
    freemove_portal.connect("body_entered", self, "_freemove_portal_activated")


func _reflection_portal_activated(body: Node):
    if body is KinematicBody:
        reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE
        Globals.origin.reset_to_parent()


func _freemove_portal_activated(body: Node):
    if body is KinematicBody:
        if body.has_method("switch_to_freelook_mover"):
            body.switch_to_freelook_mover()
