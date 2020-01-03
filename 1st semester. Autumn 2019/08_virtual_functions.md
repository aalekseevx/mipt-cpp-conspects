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

Note: `static_cast` anyway is able to cast up the inheritance hierarchy.
