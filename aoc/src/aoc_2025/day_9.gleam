import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

fn rectangle_area(a: Point, b: Point) -> Int {
  { int.absolute_value(a.x - b.x) + 1 } * { int.absolute_value(a.y - b.y) + 1 }
}

pub fn parse(input: String) -> List(Point) {
  use row <- list.map(string.split(input, "\n"))
  let assert Ok([x, y]) =
    string.split(row, ",") |> list.map(int.parse) |> result.all
  Point(x, y)
}

pub fn pt_1(input: List(Point)) {
  let assert Ok(biggest_area) =
    input
    |> list.combination_pairs()
    |> list.map(fn(x) { rectangle_area(x.0, x.1) })
    |> list.sort(fn(x, y) { int.compare(y, x) })
    |> list.first()
  biggest_area
}

pub fn right_turn(p1: Point, p2: Point, p3: Point) -> Bool {
  case p2.x - p1.x, p2.y - p1.y {
    a, 0 if a > 0 -> p3.y - p2.y > 0
    a, 0 if a < 0 -> p3.y - p2.y < 0
    0, a if a > 0 -> p3.x - p2.x < 0
    0, a if a < 0 -> p3.x - p2.x > 0
    _, _ -> True
  }
}

fn point_inside(point: Point, corner1: Point, corner2: Point) -> Bool {
  {
    { corner1.x < point.x && point.x < corner2.x }
    || { corner2.x < point.x && point.x < corner2.x }
  }
  && {
    { corner1.y < point.y && point.y < corner2.y }
    || { corner2.y < point.y && point.y < corner2.y }
  }
}

fn green_rectangle(tiles: List(Point), t1: Point, t2: Point, t3: Point) -> Bool {
  right_turn(t1, t2, t3) && !list.any(tiles, fn(x) { point_inside(x, t1, t3) })
}

fn area_of_biggest_green_rectangle(
  first_tile: Point,
  second_tile: Point,
  all_tiles: List(Point),
  biggest_area: Int,
  tiles: List(Point),
) -> Int {
  case tiles {
    [t1, t2, t3, ..rest] -> {
      let new_biggest_area = case green_rectangle(all_tiles, t1, t2, t3) {
        True -> {
          int.max(biggest_area, rectangle_area(t1, t3))
        }
        False -> {
          biggest_area
        }
      }
      area_of_biggest_green_rectangle(
        first_tile,
        second_tile,
        all_tiles,
        new_biggest_area,
        [t2, t3, ..rest],
      )
    }
    [t1, t2] -> {
      case green_rectangle(all_tiles, t1, t2, first_tile) {
        True -> int.max(biggest_area, rectangle_area(t1, first_tile))
        False -> biggest_area
      }
    }
    [t1] -> {
      case green_rectangle(all_tiles, t1, first_tile, second_tile) {
        True -> int.max(biggest_area, rectangle_area(t1, second_tile))
        False -> biggest_area
      }
    }
    [] -> 0
  }
}

pub fn pt_2(input: List(Point)) {
  let assert [first_tile, second_tile, ..] = input
  area_of_biggest_green_rectangle(first_tile, second_tile, input, 0, input)
}
