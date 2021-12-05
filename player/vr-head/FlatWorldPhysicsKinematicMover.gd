extends KinematicBodyMover
class_name FlatWorldPhysicsKinematicMover


const SNAP_VECTOR = Vector3(0, -1, 0)
const UP_DIRECTION = Vector3(0, 1, 0)
const STOP_ON_SLOPE = true
const MAX_SLIDES = 4
const FLOOR_MAX_ANGLE = 0.785398
const INFINITE_INERTIA = false


export var GRAVITY_ACCELERATION_MPS2 = 9.81
export var NORMAL_ACCELERATION_MPS2 = 9
export var SPRINT_ACCELERATION_MPS2 = 15
export var NORMAL_MAX_SPEED_MPS = 3
export var SPRINT_MAX_SPEED_MPS = 5
export var CUTOFF_VELOCITY_MPS = 0.02
export var DAMPING_COEFFICIENT_NSPM = 10
export var AIR_THICKNESS = 0.9 # affects in-air damping
export var JUMP_SPEED_MPS = 50 # overrides vertical speed
export var MASS_KG = 70
export var ROTATION_SPEED_RPS = 2*PI
# export var MOUSE_SENSITIVITY = 0.5
# export var JOYPAD_SENSITIVITY = 2
# export var JOYPAD_DEADZONE = 0.15
# export var MOUSE_SENSITIVITY_SCROLL_WHEEL = 0.08


var max_speed = NORMAL_MAX_SPEED_MPS
var max_acceleration = NORMAL_ACCELERATION_MPS2
var velocity = Vector3()


func process(delta: float, body: KinematicBody):
    var origin = Globals.origin as VrOrigin
    apply_rotation_and_fix_offset(delta, origin)
    apply_movement(delta, origin, body)
    follow_body_with_camera(origin, body)


func follow_body_with_camera(origin: VrOrigin, body: KinematicBody) -> void:
    var offset = body.global_transform.origin - origin.head.global_transform.origin
    body.translation = Vector3()
    origin.global_translate(offset)


func apply_movement(dt: float, origin: VrOrigin, body) -> void:
    calculate_sprint()
    apply_dampening(dt, body)
    velocity.y -= GRAVITY_ACCELERATION_MPS2 * dt # apply gravity
    accelerate_from_inputs(dt, origin, body)
    velocity = body.move_and_slide_with_snap(velocity, SNAP_VECTOR, UP_DIRECTION, STOP_ON_SLOPE, MAX_SLIDES, FLOOR_MAX_ANGLE, INFINITE_INERTIA)


func accelerate_from_inputs(dt: float, origin: VrOrigin, body: KinematicBody) -> void:
    if body.is_on_floor():
        var input_vector = get_velocity_input_vector(body, origin.left)
        input_vector.y = 0
        if input_vector.length() > 1:
            input_vector = input_vector.normalized()
        var target_velocity = input_vector * max_speed
        var vertical = velocity.y
        velocity.y = 0
        var ideal_dv = target_velocity - velocity
        velocity.y = vertical
        var max_dv = max_acceleration * dt
        if ideal_dv.length() < max_dv:
            velocity = target_velocity
        else:
            var dv = ideal_dv.normalized() * max_dv
            velocity += dv
        if Input.is_action_pressed("movement_jump"):
            velocity.y = JUMP_SPEED_MPS


func apply_dampening(dt: float, body: KinematicBody) -> void:
    if velocity.length() > CUTOFF_VELOCITY_MPS:
        # F = c*v
        # F = m*a -> a = F/m
        # dV = a*dt
        var damping_ratio = DAMPING_COEFFICIENT_NSPM * dt / MASS_KG
        if not body.is_on_floor():
            damping_ratio *= AIR_THICKNESS
        if damping_ratio < 1:
            velocity *= (1 - damping_ratio)
        else:
            velocity = Vector3()


func calculate_sprint() -> void:
    var sprint = 1 if Input.is_action_pressed("movement_sprint") else 0 # TODO add VR sprinting capability by hand movement
    max_speed = NORMAL_MAX_SPEED_MPS + sprint * (SPRINT_MAX_SPEED_MPS - NORMAL_MAX_SPEED_MPS)
    max_acceleration = NORMAL_ACCELERATION_MPS2 + sprint * (SPRINT_ACCELERATION_MPS2 - NORMAL_ACCELERATION_MPS2)


func apply_rotation_and_fix_offset(delta: float, origin) -> void:
    var offset_from_rotation = apply_rotation_and_calculate_offset(delta, origin)
    origin.global_translate(-offset_from_rotation)


func apply_rotation_and_calculate_offset(delta: float, origin) -> Vector3:
    var old = origin.head.global_transform.origin
    apply_rotation(delta, origin)
    var new = origin.head.global_transform.origin
    return new - old


func apply_rotation(delta: float, origin) -> void:
    origin.rotate_y(get_player_rotation_amount(delta, origin.right))


func get_velocity_input_vector(body, left) -> Vector3:
    return get_forward_velocity_input_vector(body, left) + get_rightward_velocity_input_vector(body, left)


func get_forward_velocity_input_vector(body, left) -> Vector3:
    return -body.global_transform.basis.z * left.get_biaxial_analog_input_vector().y


func get_rightward_velocity_input_vector(body, left) -> Vector3:
    return body.global_transform.basis.x * left.get_biaxial_analog_input_vector().x


func get_player_rotation_amount(delta: float, right) -> float:
    return -right.get_biaxial_analog_input_vector().x * delta * ROTATION_SPEED_RPS