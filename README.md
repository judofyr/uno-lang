# Uno

Uno is a small language with a weird bag of features. It's object-oriented
(with inheritance), but everything is immutable. It's dynamically typed, but
supports pattern matching. It's very functional, but doesn't have automatic
currying or point-free style.

It's based upon ["Extensible records with scoped labels"][xrecords] by Daan
Leijen.

And no, you can't run it yet.

## Basics

Variables, integers and strings:

```
n = 10
s = "Magnus"
```

Blocks:

```
plus = [ |a, b| a + b ]
p(plus(1, 2))
```

Records:

```
point = { x: 10, y: 10 }
point.x  # => 10
point.y  # => 10
point.z  # => Error!
```

Extensible records:

```
b = { point, x: 20 }
b.x  # => 20
b.y  # => 10
```

And here's the real trick: They are scoped. The old x-field is still stored in
the record, it's just hidden:

```
c = { b, -x }  # Start with b, remove the x-field
c.x  # => 10
c.y  # => 10
```

And records can also contain blocks:

```
Math = {
  sqrt: [ … ]
}

Math.sqrt(10)
```

### Objects

Objects are simple:

```
Point = Object:sub({
  x:~ [ self.x ]
  y:~ [ self.y ]
  length:~ [ Math.sqrt(self.x ** 2 + self.y ** 2) ]
})

point = Point:new({x: 10, y: 10})
point.x  # => 10 (direct access)
point:x  # => 10 (method call)
```

I'm going to tell a secret: This is just sugar around records.

```
Point = {
  methods: {
    x: [ |env, self| self.x ]
    y: [ |env, self| self.y ]
    length: [ |env, self| Math.sqrt(self.x ** 2 + self.y ** 2) ]
  }
}

point = {
  _scope: [ |self| self._class.methods ]
  _class: Point
  x: 10
  y: 10
}

# point:x is just a shortcut for:
env = point._scope(point)
env.x(env, point)
```

Objects are merely conventional in Uno. The runtime has no concept of
"objects". In fact, the `Object`-object is implemented in Uno itself. We only
have a bit of sugar to simplify method calls and method definitions.

### Patterns

A pattern in Uno is just a block:

```
Point = [ |rec|
  rec.x
  rec.y
]
```

You can then use this to match inside other blocks:

```
length = [
  |rec Point|  Math.sqrt(rec.x ** 2 + rec.y ** 2)
  |str String| String.length(str)
]

p(length({ x: 1, y: 2 }))
p(length("Hello"))
```

[xrecords]: http://legacy.cs.uu.nl/daan/pubs.html#scopedlabels

