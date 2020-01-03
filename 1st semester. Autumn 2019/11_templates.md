# Lecture 11. Templates

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
