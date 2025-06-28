class_name MathLib
extends Node

# Source: https://gist.github.com/johnsoncodehk/2ecb0136304d4badbb92bd0c1dbd8bae
static func clamp_angle(angle:float, _min:float, _max:float) -> float:
	var start:float = (_min + _max) * 0.5 - 180
	var floorVal:float = floori((angle - start) / 360) * 360
	_min += floorVal
	_max += floorVal
	return clampf(angle, _min, _max)

static func smooth_look_at(from:Node3D, target:Node3D, damp:float, delta:float) -> Quaternion:
	var look = target.global_transform.looking_at(from.position, Vector3.UP)
	return from.quaternion.slerp(Quaternion.from_euler(look.basis.get_euler()), damp * delta)
