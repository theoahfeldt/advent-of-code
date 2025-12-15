import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import nibble.{do, return}
import nibble/lexer

import gleam/dict.{type Dict}

type Token {
  Label(String)
  Colon
  Newline
  OutToken
}

pub type Output {
  Device(String)
  Out
}

fn my_lexer() {
  lexer.simple([
    lexer.token(":", Colon),
    lexer.token("\n", Newline),
    lexer.token("out", OutToken),
    lexer.variable(set.new(), Label),
    lexer.whitespace(Nil)
      |> lexer.ignore,
  ])
}

fn my_parser() {
  let label_parser = {
    use tok <- nibble.take_map("expected label")
    case tok {
      Label(s) -> Some(s)
      _ -> None
    }
  }

  let out_parser = {
    use tok <- nibble.take_map("expected out")
    case tok {
      OutToken -> Some(Out)
      _ -> None
    }
  }

  let row = {
    use label <- do(label_parser)
    use _ <- do(nibble.token(Colon))
    use outputs <- do(
      nibble.many1(
        nibble.one_of([label_parser |> nibble.map(Device), out_parser]),
      ),
    )
    return(#(label, outputs))
  }

  nibble.sequence(row, nibble.token(Newline)) |> nibble.map(dict.from_list)
}

pub fn parse(input: String) -> Dict(String, List(Output)) {
  let assert Ok(tokens) = lexer.run(input, my_lexer())
  let assert Ok(result) = nibble.run(tokens, my_parser())
  result
}

fn num_paths_to_out(
  from: Output,
  devices: Dict(String, List(Output)),
) -> Result(Int, Nil) {
  case from {
    Device(label) -> {
      use outputs <- result.try(dict.get(devices, label))
      use num_paths <- result.map(
        outputs |> list.map(num_paths_to_out(_, devices)) |> result.all,
      )
      int.sum(num_paths)
    }
    Out -> Ok(1)
  }
}

pub fn pt_1(input: Dict(String, List(Output))) {
  num_paths_to_out(Device("you"), input)
}

fn num_paths(
  devices: Dict(String, List(Output)),
  from: Output,
  to: Output,
) -> Result(Int, Nil) {
  case from, to {
    Device(label1), Device(label2) if label1 == label2 -> Ok(1)
    Device(label), _ -> {
      use outputs <- result.try(dict.get(devices, label))
      use num_paths <- result.map(
        outputs
        |> list.map(num_paths(devices, _, to))
        |> result.all,
      )
      int.sum(num_paths)
    }
    Out, Out -> Ok(1)
    Out, _ -> Ok(0)
  }
}

pub fn pt_2(devices: Dict(String, List(Output))) {
  let svr_to_fft = num_paths(devices, Device("svr"), Device("fft")) |> echo
  let svr_to_dac = num_paths(devices, Device("svr"), Device("dac")) |> echo
  let fft_to_dac = num_paths(devices, Device("fft"), Device("dac")) |> echo
  let dac_to_fft = num_paths(devices, Device("dac"), Device("fft")) |> echo
  let fft_to_out = num_paths(devices, Device("fft"), Device("out")) |> echo
  let dac_to_out = num_paths(devices, Device("dac"), Device("out")) |> echo
}
