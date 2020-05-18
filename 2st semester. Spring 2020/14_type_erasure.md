# Lecture 14. Type erasure

# Unit 16. Type erasure

## 16.1 Unions

A union is a special class type that can hold only one of its non-static data members at a time. 

Size of union is maximum of sizes of its members. Only one member is active, using others is a UB.

Not recommended to use.

```cpp
union U {
	int i;
	double d;
	std::string s;
	U(int x) : i(x) {}
	~U() {}	
}

int main() {
	U i(1);
	new(&u.s) std::string("abc");
	std::cout << u.s << std::endl;

	(u.s).~basic_string<char>();
	u.i = 2;
	std::cout << u.i;
}
```

Unions is not a good practice now. Problem: all destruction must be done explicitly a lot of UB.

## 16.2 `std::variant`

Works same as union, but much more modern and safe.
If non-active element is acceessed, throws an exception.


```cpp
int main() {
	std::variant<int, double, std::string> v;
	v = 0;
	std::cout << std::get<0>(v);
	v = "aaaaa";
}
```

`std::holds_alternative` to examine `std::variant`

```cpp
int main()
{
    std::variant<int, std::string> v = "abc";
    std::cout << std::boolalpha
              << "variant holds int? "
              << std::holds_alternative<int>(v) << '\n'
              << "variant holds string? "
              << std::holds_alternative<std::string>(v) << '\n';
```

## 16.3 `std::any`

Python-style object.

```cpp
int main() {
	std::any a = 1
	std::cout << a.type().name() << std::endl; // type() returns std::typeinfo (see 5.10)

	a = "meow"
	std::string copy = std::any_cast<std::string>(a);
	a = std::vector<int>{1, 2, 3, 4, 5};
}
```

## 16.4 Type erasure

Simplified implementation of `std::any`.

```cpp
class any {
private:
	void* objptr;

public:
	template<typename T>
	any(const T& obj) {
		objptr = new T(obj);
	}

	~any() {
		// uses vtable to call Derived destructor
		// which calls T destructor
		delete objptr;
	}

private:
	struct Base {
		// for polymorphic behaviour
		virtual ~Base() = 0;
	};

	template<typename T>
	struct Derived : public Base {
		Derived(const T& obj): x(obj) {}
	private:
		T x;
	};
}
```

In STL this is approach is not used, because there's a faster one. For each assigned object type Manager with pointers to constructor/destructor is generated and created with an object.

Same idea is behind `std::function` implementation, for every type of object inside, function will be generated.