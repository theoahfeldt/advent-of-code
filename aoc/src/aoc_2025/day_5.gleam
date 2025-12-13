import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import nibble.{do, return}
import nibble/lexer

type Token {
  Digit(Int)
  Dash
  Newline
}

pub type Range {
  Range(start: Int, end: Int)
}

fn my_lexer() {
  lexer.simple([
    lexer.token("-", Dash),
    lexer.token("\n", Newline),
    lexer.int(Digit),
  ])
}

fn my_parser() {
  let int_parser = {
    use tok <- nibble.take_map("expected number")
    case tok {
      Digit(n) -> Some(n)
      _ -> None
    }
  }

  let range = {
    use start <- do(int_parser)
    use _ <- do(nibble.token(Dash))
    use end <- do(int_parser)
    use _ <- do(nibble.token(Newline))
    return(Range(start, end))
  }

  use ranges <- do(nibble.many1(range))
  use _ <- do(nibble.token(Newline))
  use ids <- do(nibble.sequence(int_parser, nibble.token(Newline)))
  return(#(ranges, ids))
}

pub fn parse(input: String) -> #(List(Range), List(Int)) {
  let assert Ok(tokens) = lexer.run(input, my_lexer())
  let assert Ok(result) = nibble.run(tokens, my_parser())
  result
}

fn in_range(x: Int, range: Range) -> Bool {
  range.start <= x && x <= range.end
}

fn is_fresh(id: Int, ranges: List(Range)) -> Bool {
  list.any(ranges, fn(x) { in_range(id, x) })
}

pub fn pt_1(input: #(List(Range), List(Int))) {
  let #(ranges, ids) = input
  list.count(ids, fn(id) { is_fresh(id, ranges) })
}

fn combine_two_ranges(x: Range, y: Range) -> Result(Range, Nil) {
  case y.start < x.start {
    True -> combine_two_ranges(y, x)
    False ->
      // Can assume x starts before y
      case y.start <= x.end {
        True -> Ok(Range(x.start, int.max(x.end, y.end)))
        False -> Error(Nil)
      }
  }
}

fn combine_range_with_ranges(
  range: Range,
  ranges: List(Range),
) -> Result(List(Range), Nil) {
  case ranges {
    [first, ..rest] ->
      case combine_two_ranges(range, first) {
        Ok(combined) -> Ok([combined, ..rest])
        Error(_) -> {
          use combined <- result.try(combine_range_with_ranges(range, rest))
          Ok([first, ..combined])
        }
      }
    [] -> Error(Nil)
  }
}

fn combine_ranges(ranges: List(Range)) -> List(Range) {
  case ranges {
    [first, ..rest] ->
      case combine_range_with_ranges(first, rest) {
        Ok(combined) -> combine_ranges(combined)
        Error(_) -> [first, ..combine_ranges(rest)]
      }
    [] -> []
  }
}

fn num_ids_in_range(range: Range) -> Int {
  range.end - range.start + 1
}

pub fn pt_2(input: #(List(Range), List(Int))) {
  let #(ranges, _) = input
  int.sum(list.map(combine_ranges(ranges), num_ids_in_range))
}
