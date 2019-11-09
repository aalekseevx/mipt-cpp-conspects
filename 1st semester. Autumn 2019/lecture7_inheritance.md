# Lecture 7. Inheritance

## 3.10. Static functions and vars are not associated with object, but with the whole class.

```cpp

class C {
	static void f();
}

C::f();
```

## 3.11. Bit fields

```cpp
struct S {
	int a:2; // a is 2 bits
	int b:3; // b is 3 bits
}
```

Size of the object - 1 byte.

## 3.12 Nested classes

```cpp
class C {
	struct Nested {
		int g();
	}
public:
	Nested f() {}
}

int main() {
	Nested x = C().f(); // CE, because Nested is not visible 
	int x = C().f().g(); // OK
}
```

if Nested is public, use:

```cpp
C::Nested x = c().f()
```

## 3.13 Local classes are classes defined and declared in functions.

# Unit 5. Inheritance.

## 1. Idea.
```cpp
	class Base {};
	class Derived : public Base {}; // all Base features are accesible 
	class Derived : private Base {}; // public, protected -> private
	class Derived : protected Base {}; // public -> protected
```
Structs are derived public by defaul.

For outer functions Base fields are visible only if they are public and inherited public.

Protected fields are visible only for derived classes, but not for outer functions.
For all fields strictest of their type and inheritance type is chosen (public, private, protected)

Idea:
- Public - class is a special case of another clalss.
- Private - class is implemented using base class.
- Protected - providing functions for derived classes.

## 2 Search for names.

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
	void f();
}

int main() {
	B().f() //CE
}
```

f is visible, but not accesible

**Public/private Modifiers doesn't change the way compiler is looking for definitions**

Order of operations
1) Search for functions
2) Accesibility check

```cpp
struct B: A {
	int a;
private:
	using A::f; // add A::f to overloads
	void f(double);
}
```

### Friends.
Friends are not bidirected. Friends are not derived.

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

## 3. Constructors & Destructors

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

Constructors called A -> B
Destructors called B -> A

```cpp
// import base constructors ignoring copy constructor (since cpp11)
using A::A;
```


## 4. Multiple inheritance (just some problems)

### Diamond problem
Granny <- Mother
Granny <- Father
Mother <- Son 
Father <- Son 

```cpp
Son s; // 2 grannies inside
s.x s.f() is ambigious // if s, f is is from Granny
```

# Inaccessible base class problem
- Mom <- Granny 
- Mom <- Son 
- Granny <- Son (inaccesible Granny) 


## 5. Casts

A <- B

```cpp
A& a = b; (a links to part of b) // static_cast<A&>(b)
A a = b (b is sliced to A)
```

Allowed only when we are allowed to use the fact that B is derived.

## 6. Virtal functions.
```cpp
B b;
A& a = b;
a.f();
```

if f is virtual, then search of function def. is smart (chooses B::f), else it chooses (A::f).
