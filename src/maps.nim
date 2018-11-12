import random

import nimsvg

type
  vec2 = object
    x: int
    y: int
  coord = vec2

proc get_random_points(n = 100, bounds = vec2(x: 100, y: 100)): seq[coord] =
  result = new_seq[coord](n)
  for i in 0..<n:
    result[i] = coord(
      x: rand(bounds.x),
      y: rand(bounds.y)
      )

proc draw_svg(points: seq[coord], bounds = vec2(x: 100, y: 100), radius = 0.5,
    fill = "#000000", opacity = 0) =
  buildSvgFile("wow.svg"):
    svg(width=bounds.x, height=bounds.y):
      for p in points:
        circle(cx=p.x, cy=p.y, r=radius, fill=fill)

proc main() =
  draw_svg(get_random_points(1000))

randomize()
main()
