## 15.2 Lambda captures

Global functions and vars are captured by default,
local vars must be captured explictly.

```cpp
int main() {
	Point center{0.0, 0.0};

	// comparing by the distance to the center
	// captured center is const by default
	auto f = [center](const Point& left, const Point& right) {
		// center is availiable here
	}

	// capturing all vars as mutable by value
	auto f = [center](const Point& left, const Point& right) mutable {
		// center is availiable here
	}

	// capturing specific var as mutable by reference
	auto f = [&center](const Point& left, const Point& right) mutable {
		// center is availiable here
	}

	// or

	auto f = [&center](const Point& left, const Point& right) {
		// center is availiable here
	}
}
```

Capturing by const / rvalue reference is not supported, but can be done (see 15.4).

## 15.3 lambda functions as functional objects

Each lambda function is a special type.

Every captured object is a field in special type. Can be checked using `sizeof`.

Assignment of lambda copies all captured objects (must be copiable)

```cpp
struct C {
	C() = default;
	C(const C&) {
		std::cout << "A";
	}
}

int main() {
	C c;
	auto f = [c](){}; // prints "A"
	auto g = f; // prints "A"
}
```

If smth is captured by reference, default copy assignement is implicitly deleted, so lambda can't be assigned, only initialized.

Vars can't be accessed directly.

```cpp
int main() {
	auto f = [](){};
	// making local type constructible from lambda
	struct S {
		S(const decltype(f)&) {}
	}
}
```

## 15.4 Capture with initalization

Use case: capturing by move

```cpp
int main() {
	std::unique_ptr<int> p = std::make_unique<int>(1);
	auto f = [p = std::move(p)](){};
}
```

adding reference, renaming the var.

```cpp
int main() {
	std::unique_ptr<int> p = std::make_unique<int>(1);
	auto f = [&pp = p](){};
}
```

Const reference capture

```cpp
int main() {
	 auto f = [&pp = const_cast<const std::unique_ptr<int>&>(p)](){};
	 // or shorter in cpp17
	 auto h = [&pp = std::as_const(p)](){};
}
```

Since cpp20, multiple args initialization
```cpp
int main() {
	auto f = [...&args = 0]{}
	auto f = [...args = 0]{}
}
```

## 15.5 Default capture (bad!)

```cpp
int main() {
	// capture all by value
	auto f = [=](){};
	// capture all by reference
	auto f = [&](){};

	// capture all by value, except x
	auto f = [=, &x](){};
	// capture all by ref, except x
	auto f = [&, x](){};
}
```

Example of bad usage of default capture

```cpp
struct S {
	int a = 5;
	auto get_function() {
		auto f = [&](int x) {
			return x % a;
		};
		return f;
	}
};

int main()  {
	auto f = S().get_function();
	std::cout << f(13); // UB, capturing ref to tmp object
}
```

Still UB
```cpp
struct S {
	int a;
	S(int a): a(a) {}
	auto get_function() {
		// this doesn't capture fields of S
		// only `this` reference and local vars 
		auto f = [=](int x) {
			return x % a;
		}
	}
}

int main() {
	auto f = S(5).get_function();
	auto g = S(18).get_function();
	// S objects may be dead here
	std::cout << f(18) << ' ' << f(18) << '\n';
}
```

Big problem with default capture: lifetime of captured objects (e.g. this) may be shorter than lifetime of lambda.

Solution

```cpp
struct S {
	int a;
	S(int a): a(a) {}

	auto get_function() {
		// we need to write a = a, because usual
		// capture doesn't work with non-local vars
		auto f = [a = a](int x) {
			x % a;
		};
		return f;
	}
}
```

`*this` also can be captured.

General lambda function (implemented as templated class)

```cpp
int main() {
	auto ff = [](auto x, auto y){
		return x < y;
	};
}
```

In `cpp20` this syntax works in regular functions

## 15.6 `std::function`

Can be assigned with everything, which is `std::is_invokable<T, Args...>  `.

```cpp
int main() {
	// bool is return type, args are int, int
	std::function<bool(int, int)> cmp = [](int x, int y){};

}
```

Also in `type_traits` `std::invoke_result<T, Args...>` as a return type of invokation.

## 15.7 `std::bind`

Bind some args and decrease the argument number:

```cpp
int main() {
	auto binded = std::bind(cmp, std::placeholder::_1, 0);
}
```

Not readable enough, btw.
