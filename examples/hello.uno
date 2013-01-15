ClassScope = [ |self| self._class.methods ]

Object = {
  _scope: [ |self| self ]
  methods: {}
  new:~ [ |rec|
    { rec, _class: self, _scope: ClassScope }
  ]
  sub:~ [ |rec|
    { self, methods: { self.methods, rec } }
  ]
}

Person = Object:sub({
  name:~ [ self.name ]
})

SillyPerson = Object:sub({
  name:~ [ "Silly" ]
})

me = Person:new({name: "Magnus"})
puts(me:name)

you = SillyPerson:new({})
puts(you:name)

