import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type Operator {
  Sum
  Product
}

pub type Problem {
  Problem(operator: Operator, numbers: List(Int))
}

fn last_and_rest(x: List(a)) -> Result(#(a, List(a)), Nil) {
  let reversed = list.reverse(x)
  use last <- result.try(list.first(reversed))
  use rest <- result.map(list.rest(reversed))
  #(last, list.reverse(rest))
}

fn column_into_problem(column: List(String)) -> Result(Problem, Nil) {
  use #(last, rest) <- result.try(last_and_rest(column))
  use operator <- result.try(case last {
    "+" -> Ok(Sum)
    "*" -> Ok(Product)
    _ -> Error(Nil)
  })
  use numbers <- result.map(result.all(list.map(rest, int.parse)))
  Problem(operator, numbers)
}

fn split_on_whitespace(str: String) -> List(String) {
  list.filter(string.split(str, " "), fn(x) { !string.is_empty(x) })
}

fn parse_pt_1(input: String) -> List(Problem) {
  let rows: List(List(String)) =
    list.map(string.split(input, "\n"), split_on_whitespace)
  let assert Ok(problems) =
    result.all(list.map(list.transpose(rows), column_into_problem))
  problems
}

fn solve_problem(problem: Problem) -> Int {
  case problem {
    Problem(Sum, numbers) -> int.sum(numbers)
    Problem(Product, numbers) -> int.product(numbers)
  }
}

pub fn pt_1(input: String) {
  let problems = parse_pt_1(input)
  int.sum(list.map(problems, solve_problem))
}

fn parse_digits(column: List(String)) -> Result(Int, Nil) {
  column
  |> list.filter(fn(x) { x != " " })
  |> string.concat
  |> int.parse
}

fn columns_into_problems(
  problems: List(Problem),
  current_operator: Option(Operator),
  current_numbers: List(Int),
  columns: List(List(String)),
) -> List(Problem) {
  case columns {
    [first, ..rest] -> {
      let assert Ok(#(operator, digits)) = last_and_rest(first)
      let current_operator =
        option.or(current_operator, case operator {
          "+" -> Some(Sum)
          "*" -> Some(Product)
          _ -> None
        })
      case parse_digits(digits) {
        Ok(number) ->
          columns_into_problems(
            problems,
            current_operator,
            [number, ..current_numbers],
            rest,
          )
        Error(_) -> {
          let assert Some(operator) = current_operator
          let problem = Problem(operator, current_numbers)
          columns_into_problems([problem, ..problems], None, [], rest)
        }
      }
    }
    [] -> {
      let assert Some(operator) = current_operator
      let problem = Problem(operator, current_numbers)
      [problem, ..problems]
    }
  }
}

fn parse_pt_2(input: String) -> List(Problem) {
  let rows: List(List(String)) =
    input |> string.split("\n") |> list.map(string.to_graphemes)
  columns_into_problems([], None, [], list.transpose(rows))
}

pub fn pt_2(input: String) {
  let problems = parse_pt_2(input)
  int.sum(list.map(problems, solve_problem))
}
