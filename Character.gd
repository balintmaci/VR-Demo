extends KinematicBody


export var kinematic_handler: Resource


func _physics_process(delta: float):
    var h = kinematic_handler as PlayerKinematicHandler
    h._process(delta, self)
