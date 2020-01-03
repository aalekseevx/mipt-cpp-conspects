# Lecture 10. Templates specializations

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
```
