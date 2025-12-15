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
}

fn my_lexer() {
  lexer.simple([
    lexer.token(":", Colon),
    lexer.token("\n", Newline),
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

  let row = {
    use label <- do(label_parser)
    use _ <- do(nibble.token(Colon))
    use outputs <- do(nibble.many1(label_parser))
    return(#(label, outputs))
  }

  nibble.sequence(row, nibble.token(Newline)) |> nibble.map(dict.from_list)
}

pub fn parse(input: String) -> Dict(String, List(String)) {
  let assert Ok(tokens) = lexer.run(input, my_lexer())
  let assert Ok(result) = nibble.run(tokens, my_parser())
  result
}

// Too inefficient for "svr" -> "out"
fn num_paths_1(
  devices: Dict(String, List(String)),
  from: String,
  to: String,
) -> Result(Int, Nil) {
  case from == to {
    True -> Ok(1)
    False -> {
      use outputs <- result.try(dict.get(devices, from))
      use num_paths <- result.map(
        outputs |> list.map(num_paths_1(devices, _, to)) |> result.all,
      )
      int.sum(num_paths)
    }
  }
}

pub fn pt_1(input: Dict(String, List(String))) {
  num_paths_1(input, "you", "out")
}

pub type PathNums {
  PathNums(out: Int, dac: Int, fft: Int, dac_and_fft: Int)
}

fn sum_explored(x: PathNums, y: PathNums) -> PathNums {
  PathNums(
    out: x.out + y.out,
    dac: x.dac + y.dac,
    fft: x.fft + y.fft,
    dac_and_fft: x.dac_and_fft + y.dac_and_fft,
  )
}

fn num_paths_2(
  devices: Dict(String, List(String)),
  explored_devices: Dict(String, PathNums),
  from: String,
) -> Result(Int, Nil) {
  let new_explored_devices = {
    use #(device, outputs) <- list.filter_map(dict.to_list(devices))
    use explored: List(PathNums) <- result.try(
      outputs
      |> list.map(dict.get(explored_devices, _))
      |> result.all,
    )
    let explored_sum =
      list.fold(
        explored,
        PathNums(out: 0, dac: 0, fft: 0, dac_and_fft: 0),
        sum_explored,
      )
    let explored_sum = case device {
      "fft" ->
        PathNums(
          out: 0,
          dac: 0,
          fft: explored_sum.fft + explored_sum.out,
          dac_and_fft: explored_sum.dac_and_fft + explored_sum.dac,
        )
      "dac" ->
        PathNums(
          out: 0,
          dac: explored_sum.dac + explored_sum.out,
          fft: 0,
          dac_and_fft: explored_sum.dac_and_fft + explored_sum.fft,
        )
      _ -> explored_sum
    }
    Ok(#(device, explored_sum))
  }
  let new_explored_devices =
    dict.merge(explored_devices, dict.from_list(new_explored_devices))
  case dict.get(explored_devices, from) {
    Ok(explored) -> Ok(explored.dac_and_fft)
    Error(_) -> num_paths_2(devices, new_explored_devices, from)
  }
}

pub fn pt_2(devices: Dict(String, List(String))) {
  num_paths_2(
    devices,
    dict.from_list([
      #("out", PathNums(out: 1, dac: 0, fft: 0, dac_and_fft: 0)),
    ]),
    "svr",
  )
}
