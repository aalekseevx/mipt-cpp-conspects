## Lecture 12. Complile-time tricks


## 14.9 Reflection

Reflection is an ability to interact with meta parameters
in runtime, (e.g. list of methods, fields count)

Reflection is not supported in cpp now, so we use this kind of tricks:

```cpp
// ubiquitous, convertible to any type
struct ubiq
{
	template<typename T>
	operator T();
};


// adding fake argument to ubiq
template<typename T>
using ubiq_constructor = ubiq

// good branch of sfinae, trying to initialize T with (sizeof...(I) + 1) arguments 
template<typename T, std::size_t I0, std::size_t... I>
constexpr auto detect_fields_count(std::size_t& out, std::index_sequence<I0, I...>)
	-> decltype(T{ ubiq_constructor<I0>{}, ubiq_constructor<I>{}... }) {
		out = sizeof...(I) + 1;
	}

// bad branch, trying a smaller number of args
template <class T, std::size_t... I>
constexpr void detect_fields_count(std::size_t& out, std::index_sequence<I...>) {
	detect_fields_count<T>(out, std::make_index_sequence<sizeof...(I) - 1>{});
}

// example usage
struct S {
	int x;
	double d;
}

int main() {
	size_t x;
	detect_fields_count<S>(x, std::make_index_sequence<100>{});
	std::cout << x << '\n';
}
```


## 14.10 `common_type`

```cpp
struct common_type
{
	// common_type is embeded in operator "? :"
	using type = decltype(true ? declval<U>() : declval<V>());
};

template<typename Head, typename... Tail>
struct common_type {
	using type = common_type<Head, common_type<Tail...>>::type;
};
```

Note: Some of `type_traits` features are compiler-based.

## `constexpr` keyword

```cpp
// will be compile-time calculated
// if called in constexpr context
constexpr int g() {
	return 0;
}

int main() {
	constexpr int x = g();
}
```

Initially, `constexpr` function was just `return value`
There is a big list of avaliable features now.

Still banned:
- `throw`
- non-trivial objects
- `new` / `delete` calls

`new` / `delete` may be supported in the future. Memory will be used during compilation.

Throw is allowed only if compiler guaranties it can't be executed during compilation. Example of usage of function in both types of context:

```cpp
constexpr int g(int a) {
	return a == 1 ? throw 1 : 0;
}

int main() {
	constexpr int x = g(0);
	int y = g(1); // throws
}
```

`consteval` must be executed in compile time.

## 14.11 static_assert

```cpp
int main() {
	static_assert(value, "Value shall be true"); // checks compile-time constants
}
```

# Unit 15. Lambda functions and elements of functional programming

Interpreting function as an object

```cpp
int main() {
	// type will be specially created for the function
	// so we use auto
	auto f = [](int x, int y) {
		return x > y;
	}
	std::sort(v.begin(), v.end(), f);
}
```

