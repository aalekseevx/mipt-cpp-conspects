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
