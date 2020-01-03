# Lecture 7. Inheritance

## 3.10. Static functions and variables are not associated with an object, but with the whole class.

```cpp

class C {
	static void f();
}

// call
C::f();
```

## 3.11. Bit fields

Better use signed/unsigned expicitly. Vars like this can't be used in complicated structers as `std::vector`. 
```cpp
struct S {
	unsigned int a:2; // a is 2 bits. // Range 0..3
	int b:3; // b is 3 bits. Range is 0..7 or -4..3. (UB)
}
```

Size of the object - 1 byte.

## 3.12 Nested classes

```cpp
class C {
	struct Nested {
		int g() {

		}
	}
public:
	Nested f() {}
}

int main() {
	C::Nested x = C().f(); // CE, because Nested is private
	int x = C().f().g(); // strange, but OK
}
```

if `Nested` is public, use:

```cpp
C::Nested x = c().f()
```

## 3.13 Local classes are classes defined and declared in functions.

# Unit 5. Inheritance.

## 5.1. Idea.
```cpp
class Base {};
class Derived : public Base {}; // all Base features are accesible 
class Derived : protected Base {}; // public -> protected
class Derived : private Base {}; // public, protected -> private
```
Structs are derived public by default.

For outer functions Base fields are visible only if they are public and inherited public.

Protected fields are visible only for derived classes, but not for outer functions.

For all fields strictest of their type and inheritance type is chosen (public, private, protected)

Idea:
- `public` - class is a special case of another clalss.
- `private` - class is implemented using base class.
- `protected` - providing functions for derived classes.

## 5.2 Search for names.

Visible means __in scope__

Accesible means __visible and allowed to use__

```cpp
struct A {
	int a;
	void f(int);
}

struct B: A {
	int a;
	void f(double);
}

B().f(1) // is f(double)
B().A::f(1) // is f(int) (is called qulified-id)
```

```cpp

struct A {
	int a;
	void f(int);
}

struct B: A {
	int a;
private:
	// shadows A::f()
	void f();
}

int main() {
	B().f() //CE. Visible, but private
}
```

**Public/private modifiers doesn't change the way compiler is looking for definitions**

Order of operations
1) Name lookup
2) Accesibility check

```cpp
struct B: A {
	int a;
private:
	using A::f; // add A::f to overloads, then lookup is happening by overloading rules
	void f(double);
}
```

### Friends.
Friends are not bidirected. Friends are not derived (at all!).

### Example of strange behaviour

```cpp
struct Granny {
	void f(int);
	int a;
}

struct Mum: private Granny {
	void f(double); int a;
	// friend struct Son;
}

struct Son: public Mom {
	void f() {
		Son::Mom m;
		Granny g; // CE. It's Son::Granny, which is private. (works ok if friend)
		::Granny g; // OK
	}
}
```

## 5.3. Constructors & Destructors

```cpp
class A {
public:
	int a;
}
class B {
	int b;
	B (int b): A() /*(nothing <=> initialize A by default)*/ {
		
	}
}

// OR

class B {
	int b;
	B (int a, int b): a(a), b(b){
		
	}
}
```

Constructors called "Base, then Derived". 
Destructors called "Derived, then Base".

```cpp
// import base constructors ignoring copy constructor (since cpp11)
using A::A;
```


## 5.4. Multiple inheritance (just some problems)

### Diamond problem
- `Granny` <- `Mother`
- `Granny` <- `Father`
- `Mother` <- `Son`
- `Father` <- `Son` 

```cpp
Son s; // 2 grannies inside
s.x s.f() is ambigious // if x, f is is from Granny
```

# Inaccessible base class problem
- `Mom` <- `Granny` 
- `Mom` <- `Son` 
- `Granny` <- `Son`

`Granny` is inaccessible.

## 5.5. Casts

`A` <- `B`

```cpp
A& a = b; (a links to part of b) // static_cast<A&>(b) performs static checks (compilation stage)
// reinterpret_cast doesn't perform any checks (just reinterpret pointer)
A a = b // (b is sliced and copied)
```

`static_cast` allowed only when we are allowed to use the fact that B is derived.

## 5.6. Virtual functions.
```cpp
B b;
A& a = b;
a.f();
```

if `f` is virtual, then search of function definition is smart. (It takes into accoount the fact that it's really a `B` class object and chooses `B::f`), else it chooses (`A::f`).

Class is called polymorphic when it contains virtual functions.

Virtual functions ensure that the correct function is called for an object, regardless of the expression used to make the function call.

Virtual functions are expected to be redefined in derived classes. **Signature must be exactly the same!**

Keyword `override` checks that function overrides something (protects from wrong signature). 

Keyword `final` checks that it can't be overriden in derived classes.

`final` classes can't be derived from.

