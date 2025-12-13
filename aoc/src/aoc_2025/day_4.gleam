import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  use row <- list.map(string.split(input, "\n"))
  use char <- list.map(string.to_graphemes(row))
  case char {
    "@" -> 1
    "." -> 0
    _ -> {
      echo "Invalid input"
      0
    }
  }
}

fn bool_to_int(x: Bool) -> Int {
  case x {
    True -> 1
    False -> 0
  }
}

fn num_rolls_accessable_in_row_helper(
  accessable_count: Int,
  row_above: List(Int),
  row: List(Int),
  row_below: List(Int),
) -> Int {
  // Pad every row with a 0 before calling
  case row_above, row, row_below {
    [a1, a2, a3, ..an], [b1, b2, b3, ..bn], [c1, c2, c3, ..cn] -> {
      let new_count = case b2 {
        1 -> {
          let num_adjecent_rolls = int.sum([a1, a2, a3, b1, b3, c1, c2, c3])
          bool_to_int(num_adjecent_rolls < 4) + accessable_count
        }
        _ -> accessable_count
      }
      num_rolls_accessable_in_row_helper(new_count, [a2, a3, ..an], [b2, b3, ..bn], [
        c2,
        c3,
        ..cn
      ])
    }
    [a1, a2], [b1, 1], [c1, c2] -> {
      // Rightmost column
      let num_adjecent_rolls = int.sum([a1, a2, b1, c1, c2])
      bool_to_int(num_adjecent_rolls < 4) + accessable_count
    }
    _, _, _ -> {
      echo "wut"
      accessable_count
    }
  }
}

fn num_rolls_accessable_in_row(
  row_above: List(Int),
  row: List(Int),
  row_below: List(Int),
) -> Int {
  num_rolls_accessable_in_row_helper(0, [0, ..row_above], [0, ..row], [0, ..row_below])
}

fn num_rolls_accessable_helper(accessable_count: Int, rows: List(List(Int))) {
  case rows {
    [r1, r2, r3, ..rn] -> {
      let row_count = num_rolls_accessable_in_row(r1, r2, r3)
      num_rolls_accessable_helper(accessable_count + row_count, [r2, r3, ..rn])
    }
    [r1, r2] -> {
      let padded_row = list.repeat(0, list.length(r1))
      let row_count = num_rolls_accessable_in_row(r1, r2, padded_row)
      accessable_count + row_count
    }
    _ -> {
      echo "What the helly"
      accessable_count
    }
  }
}

fn num_rolls_accessable(rows: List(List(Int))) {
  let assert Ok(first_row) = list.first(rows)
  let padded_row = list.repeat(0, list.length(first_row))
  num_rolls_accessable_helper(0, [
    padded_row,
    ..rows
  ])
}

pub fn pt_1(input: List(List(Int))) {
  num_rolls_accessable(input)
}

pub fn pt_2(input: List(List(Int))) {
  todo as "part 2 not implemented"
}
