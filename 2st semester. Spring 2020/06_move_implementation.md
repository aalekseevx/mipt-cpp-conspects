# Lecture 6. Move implementation

## 11.6 `std::move` implementation

If a variable or parameter is declared to have type T&& for some deduced type T (which is a parameter of a function, not class), that variable or parameter is a universal reference.

Also, there are two reference-collapsing rules:

- An rvalue reference to an rvalue reference becomes (“collapses into”) an rvalue reference.
- All other references to references (i.e., all combinations involving an lvalue reference) collapse into an lvalue reference.


```cpp
using return_t = typename std::remove_reference<T>::type&&;

template<typename T>
// T&& is not always a rvalue-ref. Here it is a universal reference.
return_t move(T&& value) {
	// value is under reference-collapsing
	return static_cast<return_t>(value) 
}
```

## 11.7 Perfect forwarding

```cpp
// due to reference collapsing, 
template <typename T>
T&& forward(std::remove_reference<T>& x) {
	return static_cast<T&&>(x);
}

template <typename T>
void construct(T* p, Args&&... args) {
	new(p) T(std::forward<Args>(args)...);
}
```

## 11.8 2 versions of push_back / move
```cpp
class vector {
	void push_back(T&&);
	void push_back(T&);
}
```

Second push_back copies, first push_back uses `std::move_if_noexcept`, because exception thrown in move constructor is not reliable.

Last fix of push_back: first construct new element, then copy all others, because of expressions `v.push_back(v.back())`

## 11.9 xvalue, temporary materialization, copy elision

rvalue is divided into xvalue(expired) and prvalue(pure)
glvalue(generalized) is divided into xvalue and lvalue

prvalue
- static cast
- function call, which return rvalue
xvalue

xvalue is an object, which existed, which was casted to rvalue. Now it's similar to rvalue. But xvalue can be polymorphic!

prvalue can exist without a real object underneath.

Copy elision: simplifing prvalue, example
- `T(T())`
- `T x = T()`

but xvalue doesn't work like this and this is where
`std::move` can harm the performance.

```cpp
// copy elision
T f() {
	T x;
	return x;
}

// no copy elision
T f() {
	T x;
	// becomes xvalue
	return std::move(x);
}
```

``temporary materialization`` is a prvalue casted to xvalie

```cpp
// prvalue
T x = T()
// xvalue
T x = T().f()
```

But sometimes returning `std::move(x)` is useful

```cpp
Matrix operator+(Matrix&& a, const Matrix& b) {
	a += b;
	return std::move(a);
}
```