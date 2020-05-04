# Lecture 11. SFINAE 2

## 14.6 `is_constructible` and similar

is constructible from this args?

Learn by example:
```cpp

template<typename T, typename... Args>
struct is_constructible {
private:
	template<typename TT, typename AArgs>
	static constexpr decltype(TT(declval)<AArgs>()..., bool()) f(int) {
		return true;
	}

	template<typename...>
	static constexpr bool f(...) {
		return false;
	}
public:
	static const bool value = f<T, Args>(0);
}

template<typename T>
struct is_move_constructible:
	public is_constructible<T, std::add_rvalue_reference<T>> {};

template<typename T>
struct is_nothrow_constructible
{
	template<typename TT, typename AArgs>
	static constexpr decltype(TT(declval)<AArgs>()..., bool()) f(int) {
		return noexcept(TT(declval)<AArgs>()...);
	}

	template<typename...>
	static constexpr bool f(...) {
		return false;
	}
public:
	static const bool value = f<T, Args>(0);
};

template<typename T>
conditional_t<is_nothrow_move_constructible<T>::value, T&&, const T&>
move_if_noexcept(T& x) {
	// the rvalue references will be implicitly casted to proper type
	return std::move(x);
}

// and many more in type traits


int main() {
	std::cout << is_constructible<std::vector<int>, int, int>::value; // true
	std::cout << is_constructible<std::vector<int>, int, int, int>::value; // false
}
```

## Integral constant

Struct with compile-time constant.

```cpp
template<typename T, T v>
struct integral_constant {
	static const T value = v;
}

struct true_type : public integral_constant<bool, true> {}
struct false_type : public integral_constant<bool, false> {}
```

## is_class

is type non-primitive?

```cpp
template<typename T>
struct is_class
{
	template<typename TT
	// works mostly, call destructor, but we can call constructor 
	// from references too.
	static constexpr decltype(declval(C).~C(), bool) f(int) {
		return true;
	}
	// better version, check that ptr can be casted to
	// pointer to class member, there is no class
	// member behind primitive types, nor this syntax
	// works for C& or C&&
	static constexpr decltype((int C::*)(nullptr), bool) f(int) {
		return true;
	}


	template<typename...>
	static constexpr bool f(...) {
		return false;
	}
public:
	static const bool value = f<T, Args>(0);
};
```

## is_base_of

Implementation from cpp-reference, used in `enable_shared_from_this`.

```cpp
template <typename B>
// if compiled using this function, pointer was implicitly casted
std::true_type  test_pre_ptr_convertible(const B*);
// fallback
template <typename>
std::false_type test_pre_ptr_convertible(const void*);

// if D is a reference type, D* is a CE, so we need a fallback
template <typename, typename>
auto test_pre_is_base_of(...) -> std::false_type;
// creating pointer to D* and trying to call function,
// so that pointer is implicitly casted.
template <typename B, typename D>
auto test_pre_is_base_of(int) ->
decltype(test_pre_ptr_convertible<B>(static_cast<D*>(nullptr)));

//wrapping up evetything we have
template <typename Base, typename Derived>
struct is_base_of :
        std::integral_constant<
                bool,
                is_class<Base>::value && std::is_class<Derived>::value &&
                decltype(test_pre_is_base_of<Base, Derived>(0))::value
        > {};

```

## Number of fields detection

