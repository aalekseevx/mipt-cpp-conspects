# Lecture 1. Allocators.

## 7.7 Conditional `noexcept`

`noexcept` is also an operator, not only a specificator. `noexcept(statement)` if true if statement has `new` calls, `dynamic_cast`
and some other dangerous things.

```cpp
template<typename T>
// noexcept dependent on g
void f(T& x) noexcept(noexcept(g(x))) {
	g(x);
}
```

## 7.8 Function-try block

```cpp
// The whole function in try-catch block.
void f() try {

} catch(...) {

}


// Use case. If exception is thrown in x constructor, it will be caught. 
C(const InnerClass& x): x(x) try {

} catch(...) {

}
```

# Unit 8. Allocators.

## 8.1 operator new forms

```cpp
	// basic usage: allocates memory and calls contructor
	T* p = new T(x, y, z);

	// placement new

	// Wrong (UB)
	void push_back(const T& x) {
		// arr + sz unitinalized
		*(arr + sz) = x;
	}

	// Right: placement new, p is T*
	// Still not the best realization: uses
	// system new, but we may need to use memory from the special pool.
	// (Used on servers )
	void push_back(const T& x) {
		new(arr + sz) T(x);
	}


	// Dynamic memory management.
	// Allocate uninitialized memory
	T* p = new char[n * sizeof(T)];
```

## 8.2 Operator new overloading

Operator works in 2 stages

- Allocate memory (call global function operator new(size_t))
- Run constructor of an object to create constructor at allocated memory (can't be overloaded)

**Function `operator new` is NOT what `new` call is performing. It's only the first part.**

```cpp
// global new call overloading
void* operator new(size_t n) {

}

// placement new overloading. defalut one:
T* operator new (size_t n, T* p) {
	// just returning p, cause memory was already allocated.
	return p;
}

// nothrow new, returns nullptr in case of failure
new(std::nothrow) T(...)

struct nothrow_t {}:
nothrow_t nothrow; // just a dummy object to use function overloading.
```

`operator new` can be overloaded for a specific class.

`operator new` can be overloaded with any user-defined arguments

## 8.3 Operator delete overloading

Using `cpp-20` feauture - operator delete, which does not call destructor,
class can be defined in a way so that it can be created only using `new` operator.

```cpp
// n is an integer from new int[n]
// it was saved by the compiler and passed here.
void operator delete[](void* p, size_t n) {

}
```

*TODO*
```cpp
class Base { }
class Derived { }
// delete is overloaded

Base object;
Derived& d = object;

// Correct delete opaerator will be called.
```

**Virtual function can't be static**.