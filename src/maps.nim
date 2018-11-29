import math
import sequtils
import random
import algorithm
import sugar

import nimsvg

type
  vec2 = tuple[
    x: float,
    y: float
    ]
  coord = vec2
  line = tuple[
    c: coord,
    m: float
    ]

const origin: coord = (0.0, 0.0)
const x_axis: line  = (origin, 0.0)

type colour = string

var draw_line:  seq[(line, colour)]  = @[]
var draw_point: seq[(coord, colour)] = @[]

proc grad(l: line): float = l.m.tan()

proc find_horizontal_intersection(l: line, y = 0.0): coord =
  let grad = l.grad()
  return ((l.c.x - ((l.c.y - y) / grad)), y)

proc find_vertical_intersection(l: line, x = 0.0): coord =
  let grad = l.grad()
  return (x, l.c.y - (grad * (l.c.x - x)))

proc median(ns: seq[float]): float =
  let i = ns.len() div 2
  let ms = ns.sorted(cmp)
  if ns.len() mod 2 != 0:
    return ms[i]
  else:
    return (ms[i-1] + ms[i]) / 2

proc get_random_points(n = 100, bounds = (x: 100.0, y: 100.0)): seq[coord] =
  result = new_seq[coord](n)
  for i in 0..<n:
    result[i] = (rand(bounds.x), rand(bounds.y))

proc perpendicular(l: line, c: coord): line = (c, l.m + PI/2)
proc perpendicular(l: line): line = l.perpendicular(l.c)

proc distance(a, b: coord): float =
  sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y))

proc meets(a, b: line): coord =
  let
    ma = a.grad()
    mb = b.grad()
    ca = a.find_vertical_intersection().y
    cb = b.find_vertical_intersection().y
    y = (mb * ca - ma * cb) / (mb - ma)
  return a.find_horizontal_intersection(y)

proc project(l: line, p: coord, o: coord): coord =
  let
    drop_line  = l.perpendicular(p)
    drop_point = l.meets(drop_line)
    x = o.distance(drop_point)
    y = drop_point.distance(p)
  return (x, y)

proc project(l: line, p: coord): coord =
  project(l, p, l.meets(x_axis))

proc project(l: line, ps: seq[coord]): seq[coord] =
  ps.map((p) => l.project(p))

proc unproject(l: line, p: coord): coord =
  let
    o = l.meets(x_axis)
    drop_point: coord = (o.x + p.x * cos(l.m), o.y + p.x * sin(l.m))
    t = PI - l.perpendicular().m
    unprojected = (drop_point.x - p.y * cos(t), drop_point.y - p.y * sin(t))
  return unprojected

proc get_dividing_line(points: seq[coord]): line =
  let
    rand_line: line = ((rand(100.0), rand(100.0)), rand(PI))
    projected_points = rand_line.project(points)
    median_x = projected_points.map((p) => p.x).median()
    c2 = rand_line.unproject((median_x, 0.0))
    div_line: line = (c2, rand_line.m - (PI/2))
  return div_line

proc draw() =
  build_svg_file("wow.svg"):
    svg(width=100, height=100):
      rect(x=0, y=0, width=100, height=100, fill="#FFF")
      for d in draw_point:
        let (p, c) = d
        circle(cx=p.x, cy=p.y, r=1.5, fill=c)
      for d in draw_line:
        let (l, c) = d
        var
          xa = find_horizontal_intersection(l)
          xb = find_horizontal_intersection(l, 100.0)
        line(x1=xa.x, y1=xa.y, x2=xb.x, y2=xb.y, stroke=c, `stroke-width`=1)

# TODO rewrite divide to return line and points, instead of having two separate
# functions

proc divide(l: line, ps: seq[coord]): (seq[coord], seq[coord]) =
  result = (@[], @[])
  for p in ps:
    echo p.y, " -> ", l.project(p).y
    if l.project(p).y < 0:
      result[0].add(p)
    else:
      result[1].add(p)

type triangle = tuple[a: coord, b: coord, c: coord]

# Implement the DeWall algorithm:
# https://www.sciencedirect.com/science/article/pii/S0010448597000821?via%3Dihub
# proc dewall(points: seq[coord]): seq[triangle] =
#   let l = get_dividing_line(points)
#   let subsets = l.divide(points)

proc main() =
  let
    points = get_random_points(2)
    line = get_dividing_line(points)
  draw_line.add((line, "black"))
  for p in line.divide(points)[0]:
    draw_point.add((p, "blue"))
  for p in line.divide(points)[1]:
    draw_point.add((p, "red"))

randomize()
main()
draw()
