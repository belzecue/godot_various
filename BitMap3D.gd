"""

Creates a 3D boolean array in a 2D BitMap object.
e.g. a size of 16,3,2 gives this 2D map (first and last booleans flagged):

  0123456789012345
2:---------------X 
1:---------------- 
0:---------------- Frame 1
2:---------------- 
1:---------------- 
0:X--------------- Frame 0
  0123456789012345

IMPORTANT: max dimmensions for bitmap x*y is 2,147,483,647 (signed integer).
Therefore, when working with an equi-sided 3D cube, size should be no higher than 1290.
In that case, maybe just work with 1024 as max, e.g. if representing 1-metre cubes then
the volume is 1km cubed.  Use an array of BitMap3D chunks if need be.

"""

class_name BitMap3D


export(Vector3) var size: Vector3 = Vector3.ONE * 64

const max_bits: int = 2147483647

var bitmap: BitMap = BitMap.new()
var bitmap_size_3D: Array = []


# Requires an array of three integers being x,y,z size dimensions in 3D bitmap.
func _init(size: Vector3):
	assert(size.x * size.y * size.z <= max_bits, "BitMap total bits (x*y*z) must be no more than %s." % max_bits)
	bitmap.create(Vector2(size.x, size.y * size.z))
	bitmap_size_3D = [size.x, size.y, size.z]


# Requires an array of three integers being x,y,z position in 3D bitmap.
# Zero-based index.
func get_bit(pos: Array) -> bool:
	return bitmap.get_bit(
		Vector2(
			pos[0],
			pos[1] + (pos[2] * bitmap_size_3D[1])
		)
	)


# Requires an array of three integers being x,y,z position in 3D bitmap.
# Zero-based index.
func set_bit(pos: Array) -> void:
	bitmap.set_bit(
		Vector2(
			pos[0],
			pos[1] + (pos[2] * bitmap_size_3D[1])
		),
		true
	)


# Requires an array of three integers being x,y,z position in 3D bitmap.
# Zero-based index.
func clear_bit(pos: Array) -> void:
	bitmap.set_bit(
		Vector2(
			pos[0],
			pos[1] + (pos[2] * bitmap_size_3D[1])
		),
		false
	)


func toggle_bit(pos: Array) -> void:
	if get_bit(pos) == true:
		clear_bit(pos)
	else:
		set_bit(pos)


func toggle_bit_where(pos: Array, where_state_is: bool) -> void:
	if where_state_is == get_bit(pos):
		bitmap.set_bit(
			Vector2(
				pos[0],
				pos[1] + (pos[2] * bitmap_size_3D[1])
			),
			not where_state_is
		)


func display_map() -> void:
	print("True bits: %s" % bitmap.get_true_bit_count())
	if (bitmap_size_3D[0] > 255 or (bitmap_size_3D[1] * bitmap_size_3D[2]) > 255):
		push_error("Limit of size [255,255] when printing bitmap contents.")
		return
		# Early out.
	var x_axis: String = "  "
	for i in bitmap_size_3D[0]:
		x_axis += String(i % 10)
	print(x_axis)
	for z in range(bitmap_size_3D[2] - 1, -1, -1):
		for y in range(bitmap_size_3D[1] - 1, -1, -1):
			var line: String
			for x in bitmap_size_3D[0]:
				line += "X" if get_bit([x, y, z]) else "-"
			var y_axis: int = y % int(bitmap_size_3D[1])
			print("%s:%s %s" % [
				y_axis,
				line,
				("Frame %s" % z) if y_axis == 0 else ""
			])
	print(x_axis)

