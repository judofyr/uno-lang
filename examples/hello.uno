ClassScope = [ |self| self._class.methods ]

Object = {
  _scope: [ |self| self ]
  methods: {}
  new:~ [ |rec|
    { rec, _class: self, _scope: ClassScope }
  ]
  sub:~ [ |rec|
    { self, methods:= { self.methods, rec } }
  ]
}

Person = Object:sub({
  name:~ [ self.name ]
})

SillyPerson = Object:sub({
  name:~ [ "Silly" ]
})

sayName = [ |person|
  puts(person:name)
]

me = Person:new({name: "Magnus"})
sayName(me)

you = SillyPerson:new({})
sayName(you)


Point = {
  check: [ |rec|
    rec.x; rec.y
  ]
}

foo = [
  |rec Point| rec.x + rec.y
  |rec Str|   5
  |rec|       10
]

puts(foo({ x: 1, y: 2 }))
puts(foo("Hello"))
puts(foo({ z: 1, y: 2 }))
puts(Str.length("Hello"))

