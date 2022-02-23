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

proc `+=`*(a: var Vec, b: Vec) =
  a.x += b.x; a.y += b.y; a.z += b.z

proc `-`*(a, b: Vec): Vec =
  return Vec(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z)

proc dot*(a, b: Vec): float32 =
  return a.x * b.x + a.y * b.y + a.z * b.z

proc slen*(a: Vec): float32 =
  return a.dot(a)

proc len*(a: Vec): float32 =
  return a.slen().sqrt()

proc scaled*(a: Vec, b: float32): Vec =
  return Vec(x: a.x * b, y: a.y * b, z: a.z * b)

proc normalized*(a: Vec): Vec =
  let len = a.len()
  return Vec(x: a.x / len, y: a.y / len, z: a.z / len)

proc ray_hits*(obj: Obj, ray: Vec, ray_orig: Vec): float32 =
  let ray_slen = ray.slen()
  let
    opos = obj.pos - ray_orig
    b = ray.dot(opos)
    c = ray_slen * (opos.slen() - obj.radius * obj.radius)
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

type
  Quat* = object
    x: float32
    y: float32
    z: float32
    w: float32

proc unitQuat*(): Quat =
  return Quat(x: 0.0, y: 0.0, z: 0.0, w: 1.0)

proc scaled*(a: Quat, s: float32): Quat =
  return Quat(x: a.x * s, y: a.y * s, z: a.z * s, w: a.w * s)

proc dot*(a, b: Quat): float32 =
  return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

proc slen*(a: Quat): float32 =
  return a.dot(a)

proc len*(a: Quat): float32 =
  return a.slen().sqrt()

proc normalized*(a: Quat): Quat =
  let len = a.len()
  return Quat(x: a.x / len, y: a.y / len, z: a.z / len, w: a.w / len)

proc `+`*(a: Quat, b: Quat): Quat =
  return Quat(
    x: a.x + b.x,
    y: a.y + b.y,
    z: a.z * b.z,
    w: a.w * b.w,
  )

proc `*`*(a: Quat, b: Quat): Quat =
  return Quat(
    x: a.y * b.z - a.z * b.y + a.x * b.w + a.w * b.x,
    y: a.z * b.x - a.x * b.z + a.y * b.w + a.w * b.y,
    z: a.x * b.y - a.y * b.x + a.z * b.w + a.w * b.z,
    w: -a.x * b.x - a.y * b.y - a.z * b.z + a.w * b.w,
  )

proc cnj*(a: Quat): Quat =
  return Quat(x: -a.x, y: -a.y, z: -a.z, w: a.w)

proc toVec*(a: Quat): Vec =
  return Vec(x: a.x, y: a.y, z: a.z)

proc toQuat*(a: Vec): Quat =
  return Quat(x: a.x, y: a.y, z: a.z, w: 0.0)

proc trans*(this: Quat, src: Vec): Vec =
  let qret = this * src.toQuat() * this.cnj()
  return qret.toVec

proc quatrotquat*(a: Quat, v: Vec): Quat =
  let q = toQuat(v)
  var qr = q * a
  qr = qr + a
  return qr

proc angleAxis*(angle: float32, axis: Vec): Quat =
  let
    sangle = (angle / 2.0).sin
  return Quat(x: axis.x * sangle, y: axis.y * sangle, z: axis.z * sangle, w: (angle / 2.0).cos)