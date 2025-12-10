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

pub fn pt_1(input: List(Int)) {
  todo as "part 1 not implemented"
}

pub fn pt_2(input: List(Int)) {
  todo as "part 2 not implemented"
}
