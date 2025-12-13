import aoc_2025/day_7
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"

  assert greeting == "Hello, Joe!"
}

pub fn day_7_simulation_step_test() {
  let spaces_with_beams = [True, False, True, False, False]
  let spaces_with_splitters = [False, False, True, False, False]
  let new_beams = [True, True, False, True, False]
  let num_splits = 1
  assert day_7.simulation_step(spaces_with_beams, spaces_with_splitters)
    == #(new_beams, num_splits)
}
