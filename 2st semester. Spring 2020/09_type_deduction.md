# Lecture 9. Type deduction

## 13.1 Motivation

```cpp
// performs a lot of copies, because in map keys are const
// easy to forget
for (const std::pair<MySpecialType, std::string>& item: m) {

}

//good

for (auto it = m.begin(); it != m.end() ++it) {

}

for (auto item: m) {

}

for (const auto& item: m) {

}
```

## 13.2 Deduction types and use cases

Type, which is deducted by auto is the return type without any references. Define references explicitly

```cpp
auto&x = g();
// x is an universal link to. Can be both lvalue and rvalue.
auto&& x = g();
```

Writing auto is safe, no unnecessary copies are made.
Common:
- `const auto& x = f()`
- `auto z = static_cast<MyType>(f())`

```cpp
// ok
auto f(int x) {
	return 5
}

//absolutely not ok
auto f(int x) {
	if(x > 0) {
		return "abc";
	}
	return 5
}
```

## 13.4 decltype (declared type)

Getting type of expression in compile-time

```cpp

template<typename T>
void g() {}
int main() {
	int x = 1;
	g<decltype(f(x))>();
}
```

Dirty hack to print type in compiler errors
```cpp
template<typename T>
class Inspector {
	Inspector() = delete;
}

int main() {
	Inspector<decltype(f(x))> x;
}
```

Decltype is the only way to distinguish reference from original object.

Interesting example
```cpp
struct Base {
	void f() {
		std::cout << 1;
	}
}

struct Derived: Base
{
	void f() {
		std::cout << 2;
	}
};

int main() {
	(false ? Base() : Derived()).f()
	// can be casted only to Base
	// 1 if func is not virtual, 2 otherwise.
}
```

`decltype(x)` is int, `decltype((x))`  is int& as an expression.

when return type is dependent on arguments and `auto` is not
suitable because of its deduction rules, following syntax used

```cpp
template <typename Container>
auto getElement(Container& c, size_t i) -> decltype(c[i]) {
	return c[i];
}

// it means the following, but the following syntax doesn't work
decltype(c[i]) getElement(Container& c, size_t i) {
	return c[i];
}
```

To get rid of remove-reference rules in auto, since `cpp-14`,
use `decltype(auto)`

Example

```cpp
template<typename Container>
decltype(auto) getElement(Container& c, size_t i) {
	return c[i];
}

int main() {
	decltype(auto) = std::move(5);
}

```

Structure bindings for simple structures since cpp-17.

```cpp
for(auto& [key, value]: v) {

}
```
