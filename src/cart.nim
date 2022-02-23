import cart/wasm4
import std/math
import std/sequtils
import linalg

# Call NimMain so that global Nim code in modules will be called, 
# preventing unexpected errors
proc NimMain {.importc.}

proc start {.exportWasm.} = 
  NimMain()

type
  Position = object
    x: int
    y: int

var sun_phase = 0.0

var earth = Obj(pos: Vec(x: 0.0, y: 0.0, z: 20.0), radius: 3.0)
var sun = Obj(pos: Vec(x: 0.0, y: 0.0, z: 20.0), radius: 2.0)

proc putPixel(x: uint, y: uint, pixel: uint8) =
  var buf = FRAMEBUFFER[x.div(4) + y * SCREEN_SIZE.div(4)].addr
  buf[] = buf[] or uint8(pixel shl ((x mod 4) * 2))

proc shade_earth(x: uint, y: uint, ray: Vec, t: float32) =
  let
    hit_point = ray.scaled(t)
    delta_sun = hit_point - sun.pos
    earth_normal = hit_point - earth.pos
    sp = delta_sun.dot(earth_normal)
  var color: uint8 = if 0.0 < sp: 1 else: 2
  putPixel(x, y, color)

proc update {.exportWasm.} =
  let NEW_PALETTE: array[4, uint32] = [0x000033'u32, 0x3f3f5f, 0x5f5f8f, 0xffffff]
  PALETTE[] = NEW_PALETTE

  let
    x_offset = 0
    y_offset = 0

  for y in 0..<SCREEN_SIZE:
    for x in 0..<SCREEN_SIZE:
      var
        ray = Vec(
          x: float32(x) - SCREEN_SIZE / 2.0,
          y: float32(y) - SCREEN_SIZE / 2.0,
          z: float32(SCREEN_SIZE)
        )

      let
        inside_earth = ray_hits(earth, ray)
        inside_sun = ray_hits(sun, ray)
      if inside_earth < Inf and inside_sun < Inf:
        if inside_earth < inside_sun:
          shade_earth(uint(x), uint(y), ray, inside_earth);
        else:
          put_pixel(uint(x), uint(y), 3)
      elif inside_earth < Inf:
        shade_earth(uint(x), uint(y), ray, inside_earth);
      elif inside_sun < Inf:
        put_pixel(uint(x), uint(y), 3)


  sun.pos.x = float32(sun_phase.cos() * 10.0)
  sun.pos.y = float32(sun_phase.sin() * 1.5)
  sun.pos.z = float32(sun_phase.sin() * 10.0 + 20.0)
  sun_phase = (sun_phase + 0.01) mod (2.0 * PI)
