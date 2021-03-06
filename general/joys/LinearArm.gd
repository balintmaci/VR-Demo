tool
extends Spatial


export var value = 0.0 setget set_value, get_value
onready var joy_body = $JoyBody
onready var handler = NodeUtilities.get_child_of_type(joy_body, GrabHandler)


func set_value(v):
    if joy_body:
        value = v
        joy_body.translation.z = -v*handler.linear_limit.z


func get_value():
    if joy_body:
        return -joy_body.translation.z/handler.linear_limit.z
    else:
        return value
