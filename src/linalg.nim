import std/math

type
  Vec* = object
    x*: float32
    y*: float32
    z*: float32

  Obj* = object
    pos*: Vec
    radius*: float32

proc `+`*(a, b: Vec): Vec =
  return Vec(x: a.x + b.x, y: a.y + b.y, z: a.z + b.z)

proc `-`*(a, b: Vec): Vec =
  return Vec(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z)

proc dot*(a, b: Vec): float32 =
  return a.x * b.x + a.y * b.y + a.z * b.z

method slen*(a: Vec): float32 =
  return a.dot(a)

method len*(a: Vec): float32 =
  return a.slen().sqrt()

method scaled*(a: Vec, b: float32): Vec =
  return Vec(x: a.x * b, y: a.y * b, z: a.z * b)

proc normalized*(a: Vec): Vec =
  let len = a.len()
  return Vec(x: a.x / len, y: a.y / len, z: a.z / len)

proc ray_hits*(obj: Obj, ray: Vec): float32 =
  let ray_slen = ray.slen()
  let
    b = ray.dot(obj.pos)
    c = ray_slen * (obj.pos.slen() - obj.radius * obj.radius)
    # delta = obj.pos - ray.scaled(b)
    discrim = b * b - c
  if discrim < 0:
      return Inf
  let d = discrim.sqrt()
  let t0 = (b - d) / ray_slen
  let t1 = (b + d) / ray_slen
  if t0 < 0.0:
      return Inf
  return t0

