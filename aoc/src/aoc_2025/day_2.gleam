import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import nibble.{do, return}
import nibble/lexer

type Token {
  Dash
  Comma
  Digit(Int)
}

pub type Range {
  Range(start: Int, end: Int)
}

fn my_lexer() {
  lexer.simple([
    lexer.token("-", Dash),
    lexer.token(",", Comma),
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
    return(Range(start, end))
  }

  nibble.sequence(range, nibble.token(Comma))
}

pub fn parse(input: String) -> List(Range) {
  let assert Ok(tokens) = lexer.run(input, my_lexer())
  let assert Ok(ranges) = nibble.run(tokens, my_parser())
  ranges
}

fn duplicate_digits(num: Int) -> Int {
  let as_string = int.to_string(num)
  let assert Ok(duplicated) = int.parse(string.repeat(as_string, 2))
  duplicated
}

fn power_of_ten(n: Int) -> Int {
  let assert Ok(x) = int.power(10, int.to_float(n))
  float.round(x)
}

fn increasing_range(from: Int, to: Int) -> List(Int) {
  case from <= to {
    True -> list.range(from, to)
    False -> []
  }
}

fn invalid_ids_with_num_repeating_digits(
  range_min_repeating_digits: Int,
  range_max_repeating_digits: Int,
  num_repeating_digits: Int,
) -> List(Int) {
  let min_repeating_digits =
    int.max(power_of_ten(num_repeating_digits - 1), range_min_repeating_digits)
  let max_repeating_digits =
    int.min(power_of_ten(num_repeating_digits) - 1, range_max_repeating_digits)
  list.map(
    increasing_range(min_repeating_digits, max_repeating_digits),
    duplicate_digits,
  )
}

fn invalid_ids_in_range(range: Range) -> List(Int) {
  let range_start_string = int.to_string(range.start)
  let range_end_string = int.to_string(range.end)
  let num_digits_start = string.length(range_start_string)
  let num_digits_end = string.length(range_end_string)
  let min_num_repeating_digits =
    float.round(float.ceiling(int.to_float(num_digits_start) /. 2.0))
  let max_num_repeating_digits = num_digits_end / 2
  let possible_num_repeating_digits =
    increasing_range(min_num_repeating_digits, max_num_repeating_digits)

  let range_min_repeating_digits = case num_digits_start % 2 == 0 {
    True -> {
      let assert Ok(first_half) =
        int.parse(string.drop_end(range_start_string, min_num_repeating_digits))
      let assert Ok(last_half) =
        int.parse(string.drop_start(
          range_start_string,
          min_num_repeating_digits,
        ))
      case first_half > last_half {
        True -> first_half
        False -> first_half + 1
      }
    }
    False -> power_of_ten(min_num_repeating_digits - 1)
  }

  let range_max_repeating_digits = case num_digits_end % 2 == 0 {
    True -> {
      let assert Ok(first_half) =
        int.parse(string.drop_end(range_end_string, max_num_repeating_digits))
      let assert Ok(last_half) =
        int.parse(string.drop_start(range_end_string, max_num_repeating_digits))
      case first_half > last_half {
        True -> first_half - 1
        False -> first_half
      }
    }
    False -> power_of_ten(max_num_repeating_digits * 2) - 1
  }

  list.flat_map(possible_num_repeating_digits, fn(x) {
    invalid_ids_with_num_repeating_digits(
      range_min_repeating_digits,
      range_max_repeating_digits,
      x,
    )
  })
}

pub fn pt_1(input: List(Range)) {
  let invalid_ids = list.flat_map(input, invalid_ids_in_range)
  list.fold(invalid_ids, 0, int.add)
}

pub fn pt_2(input: List(Range)) {
  todo
}
