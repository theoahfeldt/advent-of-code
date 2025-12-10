import gleam/int
import gleam/option.{None, Some}
import nibble.{do, return}
import nibble/lexer

type Token {
  L
  R
  Digit(Int)
  Newline
}

fn rotation_lexer() {
  lexer.simple([
    lexer.token("L", L),
    lexer.token("R", R),
    lexer.int(Digit),
    lexer.token("\n", Newline),
  ])
}

fn rotation_parser() {
  let int_parser = {
    use tok <- nibble.take_map("expected number")
    case tok {
      Digit(n) -> Some(n)
      _ -> None
    }
  }

  let left = {
    use _ <- do(nibble.token(L))
    use num <- do(int_parser)
    return(-num)
  }

  let right = {
    use _ <- do(nibble.token(R))
    use num <- do(int_parser)
    return(num)
  }

  let rotation = {
    use direction <- nibble.do(nibble.one_of([left, right]))
    return(direction)
  }

  nibble.sequence(rotation, nibble.token(Newline))
}

pub fn parse(input: String) -> List(Int) {
  let assert Ok(tokens) = lexer.run(input, rotation_lexer())
  let assert Ok(rotations) = nibble.run(tokens, rotation_parser())
  rotations
}

fn count_zeros(num_zeros: Int, dial_position: Int, rotations: List(Int)) -> Int {
  case rotations {
    [] -> num_zeros
    [first, ..rest] -> {
      let dial_position = {dial_position + first} % 100
      let num_zeros = case dial_position {
        0 -> num_zeros + 1
        _ -> num_zeros
      }
      count_zeros(num_zeros, dial_position, rest)
    }
  }
}

fn count_clicks(num_clicks: Int, dial_position: Int, rotations: List(Int)) -> Int {
  let num_numbers = 100
  case rotations {
    [] -> num_clicks
    [first, ..rest] -> {
      let new_position = dial_position + first
      let assert Ok(whole_rotations) = int.divide(dial_position + first, num_numbers)
      let new_clicks = case new_position > 0 {
        True -> whole_rotations
        False if dial_position == 0 -> -whole_rotations
        False -> 1 - whole_rotations
      }
      let assert Ok(dial_position) = int.modulo(new_position, num_numbers)
      count_clicks(num_clicks + new_clicks, dial_position, rest)
    }
  }
}

pub fn pt_1(input: List(Int)) {
  count_zeros(0, 50, input)
}

pub fn pt_2(input: List(Int)) {
  count_clicks(0, 50, input)
}
