#let complexity(case: "worst", value) = {
  if case == "same" {
    $Theta(#value)$
  } else if case == "worst" {
    $O(#value)$
  } else if case == "best" {
    $Omega(#value)$
  } else {
    panic("unknown complexity case: " + case + "; valid values are: 'same', 'worst', 'best'")
  }
}
