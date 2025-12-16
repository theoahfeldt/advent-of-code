import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import nibble.{do, return}
import nibble/lexer

type Token {
  SquareBracketL
  SquareBracketR
  BracketL
  BracketR
  SquigglyBracketL
  SquigglyBracketR
  Empty
  Full
  Number(Int)
  Comma
}

fn my_lexer() {
  lexer.simple([
    lexer.token("[", SquareBracketL),
    lexer.token("]", SquareBracketR),
    lexer.token("(", BracketL),
    lexer.token(")", BracketR),
    lexer.token("{", SquigglyBracketL),
    lexer.token("}", SquigglyBracketR),
    lexer.token(".", Empty),
    lexer.token("#", Full),
    lexer.token(",", Comma),
    lexer.int(Number),
    lexer.whitespace(Nil)
      |> lexer.ignore,
  ])
}

pub type Machine {
  Machine(
    light_diagram: List(Bool),
    button_schematics: List(List(Int)),
    joltage_requirements: List(Int),
  )
}

fn my_parser() {
  let int_parser = {
    use tok <- nibble.take_map("expected label")
    case tok {
      Number(n) -> Some(n)
      _ -> None
    }
  }

  let light_parser = {
    use tok <- nibble.take_map("expected light")
    case tok {
      Full -> Some(True)
      Empty -> Some(False)
      _ -> None
    }
  }

  let light_diagram = {
    use _ <- do(nibble.token(SquareBracketL))
    use lights <- do(nibble.many1(light_parser))
    use _ <- do(nibble.token(SquareBracketR))
    return(lights)
  }

  let button_schematic = {
    use _ <- do(nibble.token(BracketL))
    use schematic <- do(nibble.sequence(int_parser, nibble.token(Comma)))
    use _ <- do(nibble.token(BracketR))
    return(schematic)
  }

  let joltage_requirements = {
    use _ <- do(nibble.token(SquigglyBracketL))
    use joltages <- do(nibble.sequence(int_parser, nibble.token(Comma)))
    use _ <- do(nibble.token(SquigglyBracketR))
    return(joltages)
  }

  let row = {
    use lights <- do(light_diagram)
    use schematics <- do(nibble.many1(button_schematic))
    use joltages <- do(joltage_requirements)
    return(Machine(
      light_diagram: lights,
      button_schematics: schematics,
      joltage_requirements: joltages,
    ))
  }

  nibble.many1(row)
}

pub fn parse(input: String) -> List(Machine) {
  let assert Ok(tokens) = lexer.run(input, my_lexer())
  let assert Ok(result) = nibble.run(tokens, my_parser())
  result
}

fn can_reach_state_with_n_clicks(
  desired: Set(Int),
  buttons: List(Set(Int)),
  n: Int,
) -> Bool {
  let outcomes: List(Set(Int)) = {
    use combination <- list.map(list.combinations(buttons, n))
    list.fold(combination, set.new(), set.symmetric_difference)
  }
  list.any(outcomes, fn(x) { x == desired })
}

fn convert_lights(n: Int, lights_set: Set(Int), lights: List(Bool)) -> Set(Int) {
  case lights {
    [True, ..rest] -> convert_lights(n + 1, set.insert(lights_set, n), rest)
    [False, ..rest] -> convert_lights(n + 1, lights_set, rest)
    [] -> lights_set
  }
}

fn least_clicks_to_reach_state(
  desired: Set(Int),
  buttons: List(Set(Int)),
  clicks: Int,
) -> Int {
  case can_reach_state_with_n_clicks(desired, buttons, clicks) {
    True -> clicks
    False -> least_clicks_to_reach_state(desired, buttons, clicks + 1)
  }
}

fn least_clicks(machine: Machine) -> Int {
  let buttons = list.map(machine.button_schematics, set.from_list)
  let desired = convert_lights(0, set.new(), machine.light_diagram)
  least_clicks_to_reach_state(desired, buttons, 1)
}

pub fn pt_1(input: List(Machine)) {
  input |> list.map(least_clicks) |> int.sum
}

pub fn pt_2(input: List(Machine)) {
  todo as "part 2 not implemented"
}
