extends RefCounted
# Validate ordinary Variant framing before bytes_to_var, which otherwise reports
# engine errors on truncated input and accepts unconsumed trailing bytes. Objects,
# resources, callable and signal variants are never accepted by profile packages.
const LIMIT = 16002000
const DEPTH_LIMIT = 64
const ITEM_LIMIT = 1000000
var bytes: PackedByteArray
var offset = 0
var budget = ITEM_LIMIT
static func decode(value: PackedByteArray) -> Variant:
 var reader = load("res://src/persistence/profiles/profile_codec.gd").new()
 reader.bytes = value
 if value.size() > LIMIT or not reader._scan(0) or reader.offset != value.size():return null
 return bytes_to_var(value)
func _skip(count: int) -> bool:
 if count < 0 or count > bytes.size() - offset:return false
 offset += count;return true
func _word() -> int:
 if bytes.size() - offset < 4:return -1
 var value = bytes.decode_u32(offset);offset += 4;return value
func _text() -> bool:
 var count = _word()
 if count < 0 or count > bytes.size() - offset:return false
 var cursor = offset
 var end = offset + count
 while cursor < end:
  var first = bytes[cursor];cursor += 1
  if first < 128:continue
  var following = 1 if first >= 194 and first <= 223 else (2 if first >= 224 and first <= 239 else (3 if first >= 240 and first <= 244 else -1))
  if following < 0 or cursor + following > end:return false
  var second = bytes[cursor]
  if (first == 224 and second < 160) or (first == 237 and second > 159) or (first == 240 and second < 144) or (first == 244 and second > 143):return false
  for n in following:
   if bytes[cursor] < 128 or bytes[cursor] > 191:return false
   cursor += 1
 return _skip((count + 3) & ~3)
func _scan(depth: int) -> bool:
 budget -= 1
 if depth > DEPTH_LIMIT or budget < 0:return false
 var header = _word()
 if header < 0:return false
 var type = header & 0xffff
 var wide = bool(header & (1 << 16))
 if header & ~0x1ffff:return false
 match type:
  TYPE_NIL:return not wide
  TYPE_BOOL:return not wide and _skip(4)
  TYPE_INT,TYPE_FLOAT:return _skip(8 if wide else 4)
  TYPE_STRING,TYPE_STRING_NAME:return not wide and _text()
  TYPE_VECTOR2:return _skip(16 if wide else 8)
  TYPE_VECTOR2I:return not wide and _skip(8)
  TYPE_RECT2:return _skip(32 if wide else 16)
  TYPE_RECT2I:return not wide and _skip(16)
  TYPE_VECTOR3:return _skip(24 if wide else 12)
  TYPE_VECTOR3I:return not wide and _skip(12)
  TYPE_TRANSFORM2D:return _skip(48 if wide else 24)
  TYPE_VECTOR4,TYPE_PLANE,TYPE_QUATERNION:return _skip(32 if wide else 16)
  TYPE_VECTOR4I:return not wide and _skip(16)
  TYPE_AABB:return _skip(48 if wide else 24)
  TYPE_BASIS:return _skip(72 if wide else 36)
  TYPE_TRANSFORM3D:return _skip(96 if wide else 48)
  TYPE_PROJECTION:return _skip(128 if wide else 64)
  TYPE_COLOR:return not wide and _skip(16)
  TYPE_ARRAY,TYPE_DICTIONARY:
   if wide:return false
   var count = _word()
   if count < 0 or count > ITEM_LIMIT:return false
   if type == TYPE_DICTIONARY:count *= 2
   if count > budget or count * 4 > bytes.size() - offset:return false
   for n in count:
    if not _scan(depth + 1):return false
   return true
  TYPE_PACKED_BYTE_ARRAY:
   var count = _word()
   return not wide and count >= 0 and _skip((count + 3) & ~3)
  TYPE_PACKED_INT32_ARRAY,TYPE_PACKED_INT64_ARRAY,TYPE_PACKED_FLOAT32_ARRAY,TYPE_PACKED_FLOAT64_ARRAY,TYPE_PACKED_VECTOR2_ARRAY,TYPE_PACKED_VECTOR3_ARRAY,TYPE_PACKED_COLOR_ARRAY,TYPE_PACKED_VECTOR4_ARRAY:
   var count = _word()
   if count < 0 or count > ITEM_LIMIT:return false
   var widths = {TYPE_PACKED_INT32_ARRAY:4,TYPE_PACKED_INT64_ARRAY:8,TYPE_PACKED_FLOAT32_ARRAY:4,TYPE_PACKED_FLOAT64_ARRAY:8,TYPE_PACKED_VECTOR2_ARRAY:16 if wide else 8,TYPE_PACKED_VECTOR3_ARRAY:24 if wide else 12,TYPE_PACKED_COLOR_ARRAY:16,TYPE_PACKED_VECTOR4_ARRAY:32 if wide else 16}
   return _skip(count * widths[type])
  TYPE_PACKED_STRING_ARRAY:
   var count = _word()
   if wide or count < 0 or count > budget or count * 4 > bytes.size() - offset:return false
   budget -= count
   for n in count:
    if not _text():return false
   return true
 return false
