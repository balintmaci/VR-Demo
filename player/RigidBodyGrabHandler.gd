extends Resource
class_name RigidBodyGrabHandler


var body: RigidBody
var old_mode: int
var old_collision_layer: int
var old_collision_mask: int
var grab_point: Spatial
var hand_point: Spatial
var grab_points: Array
var velocity_calculator: NumericDerivator


func process(_delta):
    if is_grabbed():
        if body:
            if not grab_point:
                push_error("NO GRAB POINT FOUND")
            var offset = calculate_grab_point_offset()
            var body_scale = body.scale
            body.global_transform = hand_point.global_transform * offset
            body.scale = body_scale
            velocity_calculator.next(body.global_transform.origin)
        else:
            push_error("BODY NOT SET")


func calculate_grab_point_offset():
    var body_frame = body.global_transform.orthonormalized() 
    var point_frame = grab_point.global_transform.orthonormalized()
    var point_in_body_frame = body_frame.inverse() * point_frame
    return point_in_body_frame.inverse()


func on_grab(point):
    if not is_grabbed():
        old_mode = body.mode
        old_collision_layer = body.collision_layer
        old_collision_mask = body.collision_mask
    body.mode = RigidBody.MODE_STATIC
    body.collision_layer = 0
    body.collision_mask = 0
    hand_point = point
    velocity_calculator = NumericDerivator.new()
    find_closest_grab_point()
    return true


func find_closest_grab_point():
    grab_point = null
    var lowest_distance = INF
    var closest_point = null
    if grab_points:
        for point in grab_points:
            var dist = (point.global_transform.origin - hand_point.global_transform.origin).length()
            if dist < lowest_distance:
                lowest_distance = dist
                closest_point = point
        if lowest_distance == INF:
            closest_point = null
        grab_point = closest_point
    if not grab_point:
        grab_point = body


func on_release(sender, point):
    sender.disconnect("releasing", self, "on_release")
    if hand_point == point:
        body.mode = old_mode
        body.collision_layer = old_collision_layer
        body.collision_mask = old_collision_mask
        body.apply_impulse(Vector3(0, 0, 0), velocity_calculator.derived)
        hand_point = null
        return true
    return false


func is_grabbed():
    return not not hand_point
