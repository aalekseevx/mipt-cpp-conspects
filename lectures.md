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
# Lecture 8. Virtual functions.

## 5.7 Virtual destructors

```cpp
struct Base {
	// Fix:
	// ~virtual ~Base() {}
};

struct Derived: Base {
	int* p;
	Derived (int n) {
		p = new int(n)
	}
	~Derived() {
		delete p
	}
};

int main() {
	Base* rb = new Derived(5)
	delete pb
	// Memory leak: only base destructor is called.
}
```

## 5.8 Vtable

Vtable is stored in static memory. It describes what overriden functions should be called for each class. One table per polymorphic class is stored. Pointer casts doesn't change vtable.

Example 1.
```cpp
struct A {
	void f() {}
}; // sizeof(A) == 1

struct B {
	virtual void f() {}
	virtual void g() {}
    virtual void h() {}
}; // sizeof(B) == 8 (pointer to the vtable).
	
```

Example 2.

In all three: `virtual void f();`

```cpp
class Mother {
	virtual void f();
	int x;
};

class Father {
	virtual void f();
	int y;
};

class Son : public Mother, Father {
	int z;
}; // sizeof(Son) == 16. Stores two copies of vtable pointer.

// Stored as:
// [ PTR ] [ x ] [ PTR ] [ y ] z
 
```

## 5.9 Virtual inheritance

- `Granny` <- `Mother`
- `Granny` <- `Father`
- `Mother` <- `Son`
- `Father` <- `Son`

When inheritance is virtual, `Granny` object is not duplicated. It's shared and pointer is stored in each object.

Virtual and multiple inheritance are not recommended.

## 5.10 Runtime type information (RTTI)

`typeid()` is an `operator`, which works for polymorphic objects (using vtable). Returns `std::typeinfo` object, which contains hash_code and name of the type.

`dynamic_cast` uses vtable info when possible. It is used to convert pointers and references to classes up, down, and sideways along the inheritance hierarchy. 

- If convertion to pointer fails - return `nullptr`
- If convertion to reference filas - throws `std::bad_cast`


### In following examples C-style, static and dynamic casts work in different ways:

Example 1:

`Mother` <- `Son`
`Father` <- `Son`
All are polymorphic.

```cpp
int main() {
	S s;
	M* m = &s;
	static_cast<F*>(m);  // CE, can't cast Mother to Father.
	dynamic_cast<F*>(m); // OK, using RTTI
	(F*)(m) // works in a bad way using reinterpret_cast (static_cast fails)
}
```

Example 2:

- `Mother` <- `Son`
- `Father` <- `Son`
- `Granny` <- `Mother` (virtual)
- `Granny` <- `Father` (virtual)

```cpp
int main() {
	S s;
	G& g = s;
	static_cast<M&>(g);  // CE
	(M&) g; // UB. Because when inheritance is virtual, objects are not stored properly
	// (bad reinterpret_cast)
	dynamic_cast<M&>(g) // works great
}
```

Note: `static_cast` anyway is able to cast up the inheritance hierarchy.# Lecture 9. Templates.

## 5.11 Abstact classes. Pure virtual functions.

Pure virtual functions are used when general implementation can't be created, but each derived class must provide an implementation of the function.

Usage:

```cpp
struct S {
	virtual double area() = 0;
}
```

Abstract class contains at least one pure virtual function.

Abstract class objects are not allowed.

## 5.12 Problems with virtual functions.

### Problem of calling virtual function in constructors.

```cpp
struct Base {
	Base() {
		f();
	}
	virtual void f() {
		std::cout << 1;
	}

	// if function is pure virtual, it produces an runtime error:
	// "pure virtual function call"
	// virtual void f() = 0;
};

struct Derived: Base {
	Derived(): Base() {}
	void f() override {
		std::cout << 2;
	}
};

// Code prints "1", because when Base constructor is called
// Derived object is not even initialized: no point to call overriden function.
```

### Problem with default arguments in virtual functions.

```cpp
struct Base {
	Base() { }
	virtual void f(int x = 1) { }
};

struct Derived: Base {
	Derived(): Base() {}
	void f(int x = 2) override { }
};

int main() {
	Derived d;
	Base& b = d;
	b.f(); // This calls Derived function according to vtable
	// But arguments are taken from the Base class function at the compile time.
	// That was unpredictable
}
```

# Unit 6. Templates.

## 6.1 Idea.

Templates use typenames as metavariables. Implementation of one function/class/etc can be used for all suitable classes.

It helps not to duplicate code.

**Compiler does not cast types to fit into template args**.

- Function templates
```cpp
// preferable
template<typename T1, typename T2>
/// or (maybe used)
// template<class T1, class T2>
void f (T1 a, T2 b) {
	// Function f is called with a wrong template args.
	// if T1 or T2 doesn't have size method -- CE.
	a.size();
}
```
- Typedef templates (since cpp11). (Aliases)
```cpp
template<typename T>
using mi<T> = map<int, T>
```

- Variables templates
```cpp
template<class T>
constexpr T pi = T(3.1415926535897932385L);
```

Specification - template with given arguments.

Instantiation - generation of the particaular specification.

Static polymorphism - compile time using templates

Dynamic polymorphism - runtime using vtable

Note: Splitting definition and declaration with templates:

```cpp
template<typename T>
class C {
	template<typename U>
	void f(U x);
}

template<typename T>
template<typename U>
void C<T>::f(U x) {

}
```

## 6.2 Template functions overloading

```cpp
void f(int, int) {
	cout << 1;
}

template <typename T>
void f(T, T) {
	cout << 2;
}

template <typename U, typename V>
void f(U, V) {
	cout << 3;
}

// f(5, 5) is f(int, int)
// f(0.1, 0.0) is f(T, T)
// f(5, 0.1) if f(U, V)

// if there is no third overload
// f(5, 0.1) is f(int, int). (casted)
```

Euristics:
- If it fits perfect - it is chosen. 
- More specialized (less template args) - the better.

Note: specialized arguments:
```cpp
template<typename T>
void f(const T&) {

}
```

Note: default template arguments.
```cpp
template<typename T=int>
```
Note: Smart typename guess (since cpp17)
```cpp
vector v = {1, 2, 3}
```

Note: absorption of copy constructor by universal constructor.
```cpp
template<typename T>
class C {
	template<typename U>
	C(U& x) { }
	// this can be used only with a special cast (for perfect fit)
	C(const C& x) {}
}
```# Lecture 10. Templates specializations

## 6.3 Explicit template specialization

Example: `std::vector<bool>` works as bitset.

```cpp
//partial specialization
template <typename T, typename Alloc = ...>
class vector {
	// ...
}

template <typename Alloc>
class vector<bool> {

}
```
Full specialization
```cpp
template<>
class vector<bool> {

}
```
Specialization for same arguments
```cpp
template<typename T>
class C<T, T> {

}
```
Specialization for pointers, reference, etc ...
```cpp
template<typename T>
class C<T*> {

}
// When using int* it is more preferred then:
template<typename T>
class C<T> {

}

```
**Reminder - conversions to fit args are not allowed**.

### Function specialiazation

**Partial specialiazation is forbidden - use overloading**
Definition lookup uses overloading rules.

Mind order:
1) Function overloading decision
2) Specialization decision

```cpp
template<typename T>
void f(T x) {}

// it is specialization of the first template
template<>
void f(int* x) {}

template<typename T>
void f(T* x) {}

int main() {
	int x = 5;
	f(&x);
	// Chooses second template (as more precise). It has no overloadings.
	// It would have chosen full specialization if it was declared after second template.
}
```

## 6.4 Non-type template parameters

The followong non-type template parameters allowed:

- A value that has an integral type or enumeration
- A pointer or reference to a class object
- A pointer or reference to a function
- A pointer or reference to a class member function
- std::nullptr_t

```cpp
// M, N must be defined in compile time.
template<int M, int N>
class Matrix {

};
```


### Calculating Fibonacci numbers in compile time:
```cpp
template<int N>
struct Fib {
	static const int value = Fib<N - 1>::value + Fib<N - 2>::value;
};
template<>
struct Fib<0> {
	static const int value = 0;
}

template<>
struct Fib<1> {
	static const int value = 1;
}

```

Note: template arguments who are templates:

```cpp
template<typename T, template<typename, typename> class Container>
class Stack {

};

// works like that
Stack<int, std::vector>
```

## 6.5 Basic type traits

For polymorphic types, use `type_id`. These meta_functions work static.
```cpp
template<typename T, typename U>
struct is_same {
	static const bool value = false;
};
// more preferable when types are same
template<typename T, typename T> {
	static const bool value = true;
}
```

## Metafunctions to remove/add const/reference/pointer.

Also extent(decrease a dimension of an array).

**Operands are types, not objects**.

```cpp
template<typename T>
struct remove_ref {
	typedef T t;
};

template<typename T>
struct remove_ref<T&> {
	typedef T t;
};
```

Usage
```cpp
remove_ref<int&>::t a = 5;
```# Lecture 11. Templates

## 6.6 Two-phase translation

- 1st phase: basic checks on the template function/class/etc...
- 2nd phase: instanciation of the template 

### Lazy instantiation

Only neccesary classes are instantiated. Also, some unused functions can be skipped.

```cpp
template<typename T>
struct S
{
	// T::InnerType x;
	void f() {
		typename T::InnerType y;
	}
};

int main() {
	S<int> s; // works ok thanks to lazy instantiation, unless f
	// is called somewhere in the code.
	s<int>* p = nullptr; // doesn't requere instantiation
	s<int>* p = new s<int>(); // CE
}
```

### Differents with virtual functions

Because `f` address is needed for vtable.

```cpp
template<typename T>
struct  S {
	virtual void f() // CE
	// void f(); works ok
};

// ...
s<int> s;
```

## 6.7 Dependant names

```cpp
template<typename T>
struct S {
	T x;
	void f() {
		T::type x; // CE
		// is is a static field or a typename?
		T::type* x; /// CE
		// is is a multiplication or a pointer to a typename?
		typename T::type* x; // OK
	}
}
```

Note: use typename before metafunction from `type_traits`.

```cpp
template<typename T>
struct S {
	T x;
	void f() {
		T::A<5> x; // CE, is A a template?
		T::template A<5> x;
	}
}
```

## 6.8 Varadic templates (since cpp11)

Argument unpacking:
```cpp
template<typename... Args>
	void f(const Args&... args) {
		g(args) // call
		std::cout << sizeof...(args) << '\n'; // size of package
	}
```

Example 1:

// TODO: works bad
```cpp
template<typename T, typename... Args>
void print(const T& x, const Args&... args) { // args is a pack of arguments
	std::cout << x << ' ';
	print(args) // unpacking
}

void print() {}
```

Example 2:
Print elements by indexes from the vector.
```cpp
template<std::vector<int> v, size_t... Idx>
void f(const std::vector<int>& v, Idx... idx) {
	print(v[idx]...);
}
```
Usage: `f(v, 1, 2, 3, 5)`.

## 6.9 Fold expressions(since cpp17)

Unpacking in compile time.
```cpp
template<typename Head, typename... Tail>
bool isHomogeneous(Head, Tail...) {
	return (is_same<Head, Tail>::value&& ...); // iterates throw tail
}
```

```cpp
// To calculate sum
return (... + args);
// To print everything
cout << args << ...

```

// TODO Left->right / right->left ???

Traversing in trees.
```cpp
struct Node {
	int value;
	Node* left;
	Node* right;
};

// Pointers to members
Node* Node::*left = &Node::left;
Node* Node::*right = &Node::right;

template<typename Head, typename Tail>
Node* traverse(Head head, Tail... path) {
	return (head->*...->*path);
}
```



# Lecture 12-13. Exceptions.

## Basic type deduction rules

```cpp
template<typename T>
f(T x) {

}
int x;
int &y = x;

f(y) // T is int, not int&
```

### Deduction guides in global scope:

f<const char*> -> f<std::string>

# Unit 7. Exceptions.

## 7.1 Idea
When an object is thrown, programm falls up in recursion until the object is caught. It is often more accurate, than "if error" handling. If object was not caught, `std::terminate` is called. 

In standard library, only operators `dynamic_cast` and `new` throw exceptions `std::bad_cast`, `std::bad_alloc`.

If exception is called during handling of the previous, `std::terminate` is called.

`throw;` in `catch` block throws the current exception.

Usage:
```cpp
try {
	// ...
}
catch(const std::overflow_error& e)
// catch(...) means catch everything.
```

## Difference between RE and exceptions

Still an UB. Catch doesn't work here.
```cpp
try {
	int* p = new int;
	delete p;
	delete p;
} catch(...) {

}
```

`vector::at` generates `std::out_of_range_excepton`.

Exceptions can be used not to catch mistakes. For example: to exit deep for loop.

Usually, classes derived from `std::exception` is thrown. There are lib classes like `std::logic_error`, `std::runtime_error`. Constructor takes a `string` - description of the problem. It can be seen by `e.what()`.

## 7.3 Exceptions and copies.

When exception is thrown, its copy is created somewhere. If we catch not by reference, the copy will also be created.

## 7.4 Exceptions and casts.

Exceptions doesn't perform casts.
This can catch any Derived classes

```cpp
try {

} catch(Base& b) {

}
```

## 7.5 Exception in constructors.

If exception is thrown in constructor, destructor can't be called.

Solution: smart pointers.

## 7.6 Exception in destructors.

If exception is thrown in destructor, exploit to terminate can be created

```cpp
void f() {
	S s;
	throw 1;
	// here 2 exceptions are thrown and std::terminate
}
```

## 7.7 Exception specification

`noexcept` - promise not to generate exception. It's not a CE, but any `throw` will call `std::terminate`.

Conditional `noexcept(...)` is defined in compile time.