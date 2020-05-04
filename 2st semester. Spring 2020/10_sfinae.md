# Lecture 10. SFINAE.

# Unit 14. SFINAE

## 14.0 Problems

- Check iterator category
- Check method presence in class
- move_if_noexcept

## 14.1 `std::conditional`

``conditional`` works like compile-time if for meta-programming
``condtional_t`` is a typedef shorcut

```cpp
std::conditional_t<std::is_same<T, U>>::value, int, char> f(T x, U v) {

}
```

## 14.2 Basic idea of SFINAE

```cpp
template<typename T>
typename T::type f(T) {
	std::cout << 1;
	return 0;
}

template<typename...>
int f(...) {
	std::cout << 20 << '\n';
}

int main() {
	f(0);
}
```

The first version is more spocialized, but it's declaration contains code, that can't be compiled with `T=int`, so compiler
chooses more general version without CE. It doesn't work the same talking about body of the function.

## 14.3 `std::enable_if`

```cpp
template<bool B, typename T>
struct enable_if {

};

struct enable_if<true, T> {
	using type = T; 
};


template<typename T, typename = enable_if<is_lvalue_reference<T>::value, int>
int g(T x) {

}

// or the same

template<typename T>
enable_if<is_lvalue_reference<T>::value, int> g(T x) {

}
```

## 14.4 Checking presencse of method with given args

```cpp
// This implementation contains terrible bugs!
// Next one does not

template<typename Alloc, typename... Args>
struct has_method_construct {
private:
	template<typename T>
	static decltype(Alloc().construct(Args()...), char()) f(T) {
		return 0;
	}

	template<typename...>
	static int f(...) {
		return 0;
	}
public:
	static const bool value = is_same<decltype(f(0)), char>;
}
```

**This implementation does not work like SFINAE**
Reason: functions use class template arguments. So, error happened during class instantiation.

Correct implementation:

```cpp
template<typename Alloc, typename... Args>
struct has_method_construct {
private:
	template<typename AAlloc, typename AArgs>
	static decltype(AAlloc().construct(AArgs()...), char()) f(int) {
		return 0;
	}

	template<typename...>
	static int f(...) {
		return 0;
	}
public:
	static const bool value = is_same<decltype(f<Alloc, Args>(0)), char>;
}
```

Constexpr version

```cpp
template<typename Alloc, typename... Args>
struct has_method_construct {
private:
	template<typename AAlloc, typename AArgs>
	static constexpr decltype(AAlloc().construct(AArgs()...), bool()) f(int) {
		return true;
	}

	template<typename...>
	static constexpr bool f(...) {
		return false;
	}
public:
	static const bool value = f<Alloc, Args>(0);
}
```

## 14.5 Declval

Problem: Args may be NotDefaultConstructible -> SFINAE fails

Fix, using declval:

```cpp
// decltype doesn't need implementation, because decltype doesn't need to be executed
// T type may be is incomplete, that's why we make return type returning rvalue-reference.
// So, there is no reason to instantiate T. We make it rvalue to call rvalue-version of 
// construct
template<typename T>
T&& declval() noexcept;

// ... same
static constexpr decltype(declval<AAlloc>().construct(declval<AArgs>()...), bool()) f(int) {
	return true;
}
// ... same
```
