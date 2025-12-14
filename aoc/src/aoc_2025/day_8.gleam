import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Point {
  Point(x: Int, y: Int, z: Int)
}

fn distance_squared(a: Point, b: Point) -> Int {
  { a.x - b.x }
  * { a.x - b.x }
  + { a.y - b.y }
  * { a.y - b.y }
  + { a.z - b.z }
  * { a.z - b.z }
}

pub fn parse(input: String) -> List(Point) {
  use row <- list.map(string.split(input, "\n"))
  let assert Ok([x, y, z]) =
    string.split(row, ",") |> list.map(int.parse) |> result.all
  Point(x, y, z)
}

fn add_connection_to_circuits_helper(
  connection: Set(Point),
  circuits: List(Set(Point)),
  first_matched_circuit: Set(Point),
) -> List(Set(Point)) {
  case circuits {
    [circuit, ..rest] -> {
      case set.is_disjoint(circuit, connection) {
        True -> [
          circuit,
          ..add_connection_to_circuits_helper(
            connection,
            rest,
            first_matched_circuit,
          )
        ]
        False -> {
          [set.union(circuit, first_matched_circuit), ..rest]
        }
      }
    }
    [] -> [first_matched_circuit]
  }
}

fn add_connection_to_circuits(
  connection: Set(Point),
  circuits: List(Set(Point)),
) -> List(Set(Point)) {
  case circuits {
    [circuit, ..rest] -> {
      case set.is_disjoint(circuit, connection) {
        True -> [circuit, ..add_connection_to_circuits(connection, rest)]
        False -> {
          let first_matched_circuit = set.union(circuit, connection)
          add_connection_to_circuits_helper(
            connection,
            rest,
            first_matched_circuit,
          )
        }
      }
    }
    [] -> [connection]
  }
}

fn add_connections_to_circuits(
  connections: List(#(Point, Point)),
  circuits: List(Set(Point)),
) -> List(Set(Point)) {
  case connections {
    [connection, ..rest] -> {
      let connection_as_set = set.from_list([connection.0, connection.1])
      let new_circuits = add_connection_to_circuits(connection_as_set, circuits)
      add_connections_to_circuits(rest, new_circuits)
    }
    [] -> circuits
  }
}

fn generate_circuits(
  boxes: List(Point),
  num_connections: Int,
) -> List(Set(Point)) {
  let pairs = list.combination_pairs(boxes)
  let sorted_pairs =
    list.sort(pairs, fn(p1, p2) {
      int.compare(distance_squared(p1.0, p1.1), distance_squared(p2.0, p2.1))
    })
  let connections = list.take(sorted_pairs, num_connections)
  add_connections_to_circuits(connections, [])
}

pub fn pt_1(input: List(Point)) {
  let circuits = generate_circuits(input, 1000)
  circuits
  |> list.map(set.size)
  |> list.sort(fn(x, y) { int.compare(y, x) })
  |> list.take(3)
  |> int.product
}

fn last_connection_to_form_one_circuit(
  num_boxes: Int,
  connections: List(#(Point, Point)),
  circuits: List(Set(Point)),
) -> Result(#(Point, Point), Nil) {
  case connections {
    [connection, ..rest] -> {
      let connection_as_set = set.from_list([connection.0, connection.1])
      let new_circuits = add_connection_to_circuits(connection_as_set, circuits)
      case new_circuits {
        [circuit] -> {
          case set.size(circuit) == num_boxes {
            True -> Ok(connection)
            False ->
              last_connection_to_form_one_circuit(num_boxes, rest, new_circuits)
          }
        }
        _ -> last_connection_to_form_one_circuit(num_boxes, rest, new_circuits)
      }
    }
    [] -> Error(Nil)
  }
}

pub fn pt_2(input: List(Point)) {
  let num_boxes = list.length(input)
  let pairs = list.combination_pairs(input)
  let sorted_pairs =
    list.sort(pairs, fn(p1, p2) {
      int.compare(distance_squared(p1.0, p1.1), distance_squared(p2.0, p2.1))
    })
  let assert Ok(#(p1, p2)) =
    last_connection_to_form_one_circuit(num_boxes, sorted_pairs, [])
  p1.x * p2.x
}
