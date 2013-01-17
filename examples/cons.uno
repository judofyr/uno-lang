Cell = {
  check: [ |rec| rec.car; rec.cdr ]
  cons: [ |car, cdr|
    { car: car, cdr: cdr }
  ]
}

abc = Cell.cons(1, Cell.cons(2, Cell.cons(3, {})))

map = [
  |f, rec Cell|
    Cell.cons(
      f(rec.car),
      map(f, rec.cdr)
    )

  |f, nil| nil
]

show = [ |rec| map(puts, rec) ]

show(abc)
show(map([|i| i * 2], abc))


