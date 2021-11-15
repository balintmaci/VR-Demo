extends ARVRCamera


func get_forward_direction() -> Vector3:
    return global_transform.basis.z.normalized()


func get_right_direction() -> Vector3:
    return global_transform.basis.x.normalized()