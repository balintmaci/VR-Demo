extends KinematicBody


onready var origin = get_origin()


func _physics_process(delta: float) -> void:
    pass


func get_origin() -> ARVROrigin:
    var parent = get_parent()
    if "get_origin" in parent:
        return parent.get_origin()
    else:
        push_error("No get_origin in parent")
        return null
