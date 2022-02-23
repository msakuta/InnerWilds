import cart/wasm4
import std/math
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

var
  sun_phase = 0.0
  moon_phase = 0.0
  player_rot = unitQuat()

var
  earth = Obj(pos: Vec(x: 0.0, y: 0.0, z: 20.0), radius: 3.0)
  moon = Obj(pos: Vec(x: 0.0, y: 0.0, z: 20.0), radius: 1.5)
  sun = Obj(pos: Vec(x: 0.0, y: 0.0, z: 20.0), radius: 2.0)

proc putPixel(x: uint, y: uint, pixel: uint8) =
  var buf = FRAMEBUFFER[x.div(4) + y * SCREEN_SIZE.div(4)].addr
  buf[] = buf[] or uint8(pixel shl ((x mod 4) * 2))

proc shade_planet(x: uint, y: uint, ray: Vec, t: float32, obj: Obj) =
  let
    hit_point = ray.scaled(t)
    delta_sun = hit_point - sun.pos
    planet_normal = hit_point - obj.pos
    sp = delta_sun.dot(planet_normal)
  var color: uint8 = if 0.0 < sp: 1 else: 2
  putPixel(x, y, color)

proc argmin(arr: openArray[float32]): int =
  var
    mini = -1
    min = Inf
  for i in 0..<arr.len:
    if arr[i] < min:
      mini = i
      min = arr[i]

  return mini

proc update {.exportWasm.} =
  let NEW_PALETTE: array[4, uint32] = [0x000033'u32, 0x3f3f5f, 0x5f5f8f, 0xffffff]
  PALETTE[] = NEW_PALETTE

  for y in 0..<SCREEN_SIZE:
    for x in 0..<SCREEN_SIZE:
      var
        ray = player_rot.trans(Vec(
          x: float32(x) - SCREEN_SIZE / 2.0,
          y: float32(y) - SCREEN_SIZE / 2.0,
          z: float32(SCREEN_SIZE)
        ))

      let
        inside_earth = ray_hits(earth, ray)
        inside_moon = ray_hits(moon, ray)
        inside_sun = ray_hits(sun, ray)
        min = [inside_earth, inside_moon, inside_sun, Inf].argmin()
      case min:
        of 0: shade_planet(uint(x), uint(y), ray, inside_earth, earth)
        of 1: shade_planet(uint(x), uint(y), ray, inside_moon, moon)
        of 2: put_pixel(uint(x), uint(y), 3)
        else: discard

  moon.pos.x = float32(moon_phase.cos() * 7.0)
  moon.pos.y = float32(moon_phase.sin() * -0.75)
  moon.pos.z = float32(moon_phase.sin() * 7.0 + 20.0)
  moon_phase = (moon_phase + 0.02) mod (2.0 * PI)

  sun.pos.x = float32(sun_phase.cos() * 10.0)
  sun.pos.y = float32(sun_phase.sin() * 1.5)
  sun.pos.z = float32(sun_phase.sin() * 10.0 + 20.0)
  sun_phase = (sun_phase + 0.01) mod (2.0 * PI)

  var gamepad = GAMEPAD1[]

  const ROTATE_SPEED: float32 = 0.01

  if bool(gamepad and BUTTON_RIGHT):
    player_rot = player_rot * angleAxis(ROTATE_SPEED, Vec(x: 0.0, y: 1.0, z: 0.0))
    trace("Right button is down! {player_rot}")
  if bool(gamepad and BUTTON_LEFT):
    player_rot = player_rot * angleAxis(-ROTATE_SPEED, Vec(x: 0.0, y: 1.0, z: 0.0))
    trace("Left button is down! {player_rot}")
  if bool(gamepad and BUTTON_UP):
    player_rot = player_rot * angleAxis(ROTATE_SPEED, Vec(x: 1.0, y: 0.0, z: 0.0))
    trace("Right button is down! {player_rot}")
  if bool(gamepad and BUTTON_DOWN):
    player_rot = player_rot * angleAxis(-ROTATE_SPEED, Vec(x: 1.0, y: 0.0, z: 0.0))
    trace("Left button is down! {player_rot}")