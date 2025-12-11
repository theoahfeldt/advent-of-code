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

pub fn pt_1(input: List(List(Int))) {
  let max_joltages = {
    use batteries <- list.map(input)
    let #(a, b) = max_joltage(batteries)
    10 * a + b
  }
  list.fold(max_joltages, 0, int.add)
}

pub fn pt_2(input: List(List(Int))) {
  todo as "part 2 not implemented"
}
