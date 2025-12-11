import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  use row <- list.map(string.split(input, "\n"))
  use elem <- list.map(string.to_graphemes(row))
  let assert Ok(x) = int.parse(elem)
  x
}

fn max_joltage(batteries: List(Int)) -> #(Int, Int) {
  case batteries {
    [first, second] -> #(first, second)
    [first, ..rest] -> {
      let #(a, b) = max_joltage(rest)
      case int.compare(first, a) {
        order.Gt | order.Eq -> #(first, int.max(a, b))
        order.Lt -> #(a, b)
      }
    }
    _ -> #(0, 0)
  }
}

fn add_battery(new_battery: Int, batteries: List(Int)) -> List(Int) {
  case batteries {
    [first, ..rest] -> case int.compare(new_battery, first) {
      order.Gt | order.Eq -> [new_battery, ..add_battery(first, rest)]
      order.Lt -> batteries
    }
    [] -> []
  }
}

fn max_joltage_2(num_batteries: Int, batteries: List(Int)) -> List(Int) {
  case list.length(batteries) <= num_batteries {
    True -> batteries
    False -> {
      let assert [first, ..rest] = batteries
      add_battery(first, max_joltage_2(num_batteries, rest))
    }
  }
}

pub fn pt_1(input: List(List(Int))) {
  let max_joltages = {
    use batteries <- list.map(input)
    let #(a, b) = max_joltage(batteries)
    10 * a + b
  }
  int.sum(max_joltages)
}

pub fn pt_2(input: List(List(Int))) {
  let max_joltages = {
    use batteries <- list.map(input)
    let digits = list.map(max_joltage_2(12, batteries), int.to_string)
    let assert Ok(x) = int.parse(string.concat(digits))
    x
  }
  int.sum(max_joltages)
}
