import gleam/bool
import gleam/function
import gleam/int
import gleam/list
import gleam/string

fn generate_new_beams_helper(activated_splitters: List(Bool)) -> List(Bool) {
  case activated_splitters {
    [a, b, c, ..rest] -> [a || c, ..generate_new_beams_helper([b, c, ..rest])]
    [a, _] -> [a]
    _ -> []
  }
}

fn generate_new_beams(activated_splitters: List(Bool)) -> List(Bool) {
  generate_new_beams_helper([False, ..activated_splitters])
}

// Returns the beams in the next step and number of splits in the step
pub fn simulation_step(
  spaces_with_beams: List(Bool),
  spaces_with_splitters: List(Bool),
) -> #(List(Bool), Int) {
  let stopped_beams =
    list.map2(spaces_with_beams, spaces_with_splitters, bool.and)
  let continued_beams =
    list.map2(spaces_with_beams, spaces_with_splitters, fn(beam, splitter) {
      beam && !splitter
    })
  let new_beams = generate_new_beams(stopped_beams)
  let num_splits = list.count(stopped_beams, function.identity)
  let next_beams = list.map2(continued_beams, new_beams, bool.or)
  #(next_beams, num_splits)
}

fn total_num_splits(
  num_splits: Int,
  spaces_with_beams: List(Bool),
  spaces_with_splitters: List(List(Bool)),
) -> Int {
  case spaces_with_splitters {
    [first, ..rest] -> {
      let #(next_beams, num_new_splits) =
        simulation_step(spaces_with_beams, first)
      total_num_splits(num_splits + num_new_splits, next_beams, rest)
    }
    [] -> num_splits
  }
}

pub fn parse(input: String) -> List(List(Bool)) {
  use row <- list.map(string.split(input, "\n"))
  use character <- list.map(string.to_graphemes(row))
  case character {
    "S" | "^" -> True
    _ -> False
  }
}

pub fn pt_1(input: List(List(Bool))) {
  let assert [spaces_with_beams, ..spaces_with_splitters] = input
  total_num_splits(0, spaces_with_beams, spaces_with_splitters)
}

fn quantum_generate_new_beams_helper(
  num_times_activated_splitters: List(Int),
) -> List(Int) {
  case num_times_activated_splitters {
    [a, b, c, ..rest] -> [
      a + c,
      ..quantum_generate_new_beams_helper([b, c, ..rest])
    ]
    [a, _] -> [a]
    _ -> []
  }
}

fn quantum_generate_new_beams(
  num_times_activated_splitters: List(Int),
) -> List(Int) {
  quantum_generate_new_beams_helper([0, ..num_times_activated_splitters])
}

// Returns the beams in the next step and number of splits in the step
pub fn quantum_simulation_step(
  num_beams_per_space: List(Int),
  spaces_with_splitters: List(Bool),
) -> List(Int) {
  let stopped_beams =
    list.map2(
      num_beams_per_space,
      spaces_with_splitters,
      fn(num_beams, splitter) {
        case splitter {
          True -> num_beams
          False -> 0
        }
      },
    )
  let continued_beams =
    list.map2(
      num_beams_per_space,
      spaces_with_splitters,
      fn(num_beams, splitter) {
        case splitter {
          True -> 0
          False -> num_beams
        }
      },
    )
  let new_beams = quantum_generate_new_beams(stopped_beams)
  list.map2(continued_beams, new_beams, int.add)
}

fn run_quantum_simulation(
  num_beams_per_space: List(Int),
  spaces_with_splitters: List(List(Bool)),
) -> List(Int) {
  case spaces_with_splitters {
    [first, ..rest] -> {
      let next_beams = quantum_simulation_step(num_beams_per_space, first)
      run_quantum_simulation(next_beams, rest)
    }
    [] -> num_beams_per_space
  }
}

pub fn pt_2(input: List(List(Bool))) {
  let assert [spaces_with_beams, ..spaces_with_splitters] = input
  let num_beams_per_space =
    run_quantum_simulation(
      list.map(spaces_with_beams, fn(x) {
        case x {
          True -> 1
          False -> 0
        }
      }),
      spaces_with_splitters,
    )
  int.sum(num_beams_per_space)
}
